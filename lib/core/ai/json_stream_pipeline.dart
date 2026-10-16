import 'package:json_repair_flutter/json_repair_flutter.dart';
import 'streaming_snapshot.dart';

typedef JsonMapper<T> = T Function(Map<String, dynamic> json);

class JsonStreamPipeline {
  /// Cleans the raw buffer by finding the start of the JSON structure (first '{')
  /// and stripping any leading markdown or conversational text.
  static String extractJsonSubstring(String raw) {
    final firstBrace = raw.indexOf('{');
    if (firstBrace == -1) return raw.trim();
    return raw.substring(firstBrace).trim();
  }

  /// Transforms a raw text stream into a stream of typed [StreamingSnapshot]s.
  /// 
  /// - Automatically repairs partial/incomplete JSON chunks using [repairJson].
  /// - Emits the first valid non-empty snapshot immediately (TTFT trigger).
  /// - Throttles subsequent intermediate emissions by [throttleDuration] (default 50ms)
  ///   to prevent UI rebuild churn and excessive CPU usage.
  /// - Emits the final snapshot with `isComplete: true` upon stream close.
  static Stream<StreamingSnapshot<T>> bind<T>({
    required Stream<String> rawStream,
    required JsonMapper<T> mapper,
    required T initialData,
    Duration throttleDuration = const Duration(milliseconds: 50),
  }) async* {
    final buffer = StringBuffer();
    T currentData = initialData;
    DateTime lastEmitTime = DateTime.fromMillisecondsSinceEpoch(0);
    bool hasEmittedFirstToken = false;

    await for (final chunk in rawStream) {
      if (chunk.isEmpty) continue;
      buffer.write(chunk);

      final candidate = extractJsonSubstring(buffer.toString());
      if (candidate.isEmpty || !candidate.startsWith('{')) {
        continue;
      }

      final now = DateTime.now();
      final elapsed = now.difference(lastEmitTime);
      final shouldAttemptParse = !hasEmittedFirstToken || elapsed >= throttleDuration;

      if (shouldAttemptParse) {
        try {
          final decoded = repairJson(candidate, streamStable: true);
          if (decoded is Map<String, dynamic>) {
            currentData = mapper(decoded);
            hasEmittedFirstToken = true;
            lastEmitTime = now;
            yield StreamingSnapshot<T>(
              data: currentData,
              isComplete: false,
              rawChunk: chunk,
            );
          }
        } catch (_) {
          // If JSON is not yet complete enough for mapper, silently continue accumulating.
        }
      }
    }

    // Final flush on stream completion
    final finalCandidate = extractJsonSubstring(buffer.toString());
    if (finalCandidate.isNotEmpty && finalCandidate.startsWith('{')) {
      try {
        final decoded = repairJson(finalCandidate, streamStable: false);
        if (decoded is Map<String, dynamic>) {
          currentData = mapper(decoded);
        }
      } catch (_) {
        // Fallback to currentData if final parse encounters unexpected anomaly
      }
    }

    yield StreamingSnapshot<T>(
      data: currentData,
      isComplete: true,
    );
  }
}
