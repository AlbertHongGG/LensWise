import 'dart:async';

/// Represents a parsed Server-Sent Event (SSE).
class SseEvent {
  final String event;
  final String data;

  const SseEvent({this.event = 'message', this.data = ''});

  @override
  String toString() => 'SseEvent(event: $event, data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SseEvent &&
          runtimeType == other.runtimeType &&
          event == other.event &&
          data == other.data;

  @override
  int get hashCode => Object.hash(event, data);
}

/// A [StreamTransformer] that transforms a stream of individual SSE lines
/// (e.g., from [LineSplitter]) into discrete, strongly-typed [SseEvent] instances.
class SseEventDecoder extends StreamTransformerBase<String, SseEvent> {
  const SseEventDecoder();

  @override
  Stream<SseEvent> bind(Stream<String> stream) async* {
    String currentEvent = 'message';
    final StringBuffer dataBuffer = StringBuffer();

    await for (final line in stream) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (dataBuffer.isNotEmpty || currentEvent != 'message') {
          yield SseEvent(
            event: currentEvent,
            data: dataBuffer.toString(),
          );
          currentEvent = 'message';
          dataBuffer.clear();
        }
      } else if (trimmed.startsWith(':')) {
        continue;
      } else if (trimmed.startsWith('event:')) {
        currentEvent = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('data:')) {
        if (dataBuffer.isNotEmpty) {
          dataBuffer.write('\n');
        }
        dataBuffer.write(trimmed.substring(5).trim());
      }
    }

    if (dataBuffer.isNotEmpty || currentEvent != 'message') {
      yield SseEvent(
        event: currentEvent,
        data: dataBuffer.toString(),
      );
    }
  }
}
