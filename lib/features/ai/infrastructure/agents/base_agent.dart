import 'dart:convert';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';

abstract class BaseAgent<T_IN, T_OUT> {
  final AiAgentType agentType;
  final AIProvider provider;
  final AIAgentLogger logger;

  BaseAgent(this.agentType, this.provider, this.logger);

  Future<T_OUT> execute(T_IN input);

  Stream<T_OUT> executeStream(T_IN input) {
    throw UnimplementedError('This agent does not support streaming execution.');
  }

  Future<GenerateResponse> executePrompt(GenerateRequest request) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    // Convert request to a loggable Map (excluding raw images for size reasons)
    final requestLog = {
      'systemPrompt': request.systemPrompt,
      'prompt': request.prompt,
      'hasImages': request.images != null && request.images!.isNotEmpty,
      'imageCount': request.images?.length ?? 0,
    };

    try {
      final response = await provider.generate(request);
      logger.logInteraction(requestLog, response.text, startTime);
      return response;
    } catch (e, stackTrace) {
      logger.logInteraction(requestLog, {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      }, startTime);
      rethrow;
    }
  }

  Stream<GenerateResponse> executePromptStream(GenerateRequest request) async* {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    final requestLog = {
      'systemPrompt': request.systemPrompt,
      'prompt': request.prompt,
      'hasImages': request.images != null && request.images!.isNotEmpty,
      'imageCount': request.images?.length ?? 0,
      'isStream': true,
    };

    final buffer = StringBuffer();
    try {
      final stream = provider.generateStream(request);
      await for (final response in stream) {
        buffer.write(response.text);
        yield response;
      }
      logger.logInteraction(requestLog, buffer.toString(), startTime);
    } catch (e, stackTrace) {
      logger.logInteraction(requestLog, {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'partialResponse': buffer.toString(),
      }, startTime);
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
