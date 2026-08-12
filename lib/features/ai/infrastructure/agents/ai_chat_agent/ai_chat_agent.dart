import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/chat_message.dart';
import 'prompts.dart';

class AiChatRequest {
  final String systemContextPrompt;
  final List<ChatMessage> history;
  final String newQuery;

  AiChatRequest({
    required this.systemContextPrompt,
    required this.history,
    required this.newQuery,
  });
}

class AiChatAgent extends BaseAgent<AiChatRequest, String> {
  AiChatAgent(super.agentName, super.provider, super.logger);

  @override
  Future<String> execute(AiChatRequest input) async {
    final buffer = StringBuffer();

    // Inject dynamic system context (e.g. Product, Receipt, Comparison details)
    buffer.writeln(input.systemContextPrompt);
    buffer.writeln('\n--- 對話歷史 ---');

    // Inject history
    for (final msg in input.history) {
      buffer.writeln(
        buildAiChatHistory(msg.text, msg.type == ChatMessageType.user),
      );
    }

    buffer.writeln('User: ${input.newQuery}');
    buffer.writeln('AI: ');

    final request = GenerateRequest(
      systemPrompt: buildAiChatSystemPrompt(),
      prompt: buffer.toString(),
    );

    final responseText = await executePrompt(request);
    return responseText;
  }

  @override
  Stream<String> executeStream(AiChatRequest input) async* {
    final buffer = StringBuffer();

    // Inject dynamic system context
    buffer.writeln(input.systemContextPrompt);
    buffer.writeln('\n--- 對話歷史 ---');

    // Inject history
    for (final msg in input.history) {
      buffer.writeln(
        buildAiChatHistory(msg.text, msg.type == ChatMessageType.user),
      );
    }

    buffer.writeln('User: ${input.newQuery}');
    buffer.writeln('AI: ');

    final request = GenerateRequest(
      systemPrompt: buildAiChatSystemPrompt(),
      prompt: buffer.toString(),
    );

    yield* executePromptStream(request);
  }
}

final aiChatAgentProvider = Provider.autoDispose<AiChatAgent>((ref) {
  return AiChatAgent(
    'AiChat',
    ref.watch(aiProviderProvider),
    AIAgentLogger('AiChat'),
  );
});
