import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_logger.dart';

class ConsoleAILogger implements AILogger {
  @override
  void logRequest(String agentName, String prompt, {bool hasImage = false}) {
    developer.log('[START] [$agentName] Request Started (HasImage: $hasImage)\nPrompt:\n$prompt', name: 'AI');
  }

  @override
  void logResponse(String agentName, String response, Duration duration) {
    developer.log('[SUCCESS] [$agentName] Request Completed in ${duration.inMilliseconds}ms\nResponse:\n$response', name: 'AI');
  }

  @override
  void logError(String agentName, Object error, StackTrace stackTrace) {
    developer.log('[ERROR] [$agentName] Error: $error', name: 'AI', error: error, stackTrace: stackTrace);
  }
}

final aiLoggerProvider = Provider<AILogger>((ref) {
  return ConsoleAILogger();
});
