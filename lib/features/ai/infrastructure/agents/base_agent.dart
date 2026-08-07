import 'dart:convert';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_logger.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';

abstract class BaseAgent<T_IN, T_OUT> {
  final String agentName;
  final AIProvider provider;
  final AILogger logger;

  BaseAgent(this.agentName, this.provider, this.logger);

  Future<T_OUT> execute(T_IN input);

  Future<String> executePrompt(GenerateRequest request) async {
    final stopwatch = Stopwatch()..start();
    logger.logRequest(
      agentName,
      request.prompt,
      hasImage: request.images != null && request.images!.isNotEmpty,
    );

    try {
      final response = await provider.generate(request);
      stopwatch.stop();
      logger.logResponse(agentName, response.text, stopwatch.elapsed);
      return response.text;
    } catch (e, stackTrace) {
      logger.logError(agentName, e, stackTrace);
      rethrow;
    }
  }

  /// Helper to extract JSON array or object from markdown code blocks
  T extractJson<T>(String responseText) {
    final regex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = regex.firstMatch(responseText);

    String jsonString = responseText;
    if (match != null) {
      jsonString = match.group(1) ?? responseText;
    }

    return jsonDecode(jsonString.trim()) as T;
  }
}
