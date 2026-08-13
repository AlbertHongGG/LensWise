import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'prompts.dart';

import 'package:lens_wise/features/ai/domain/interfaces/i_receipt_parsing_agent.dart';
import 'package:lens_wise/features/ai/domain/models/receipt_parsing_result.dart';

class ReceiptParsingAgent
    extends BaseAgent<List<Uint8List>, ReceiptParsingResult>
    implements IReceiptParsingAgent {
  final String targetLanguage;

  ReceiptParsingAgent(
    super.agentName,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Future<ReceiptParsingResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(targetLanguage),
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    final responseText = await executePrompt(request);

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      return ReceiptParsingResult.fromJson(jsonMap);
    } catch (e) {
      return ReceiptParsingResult(
        status: 'needs_more_info',
        message: '收據解析失敗，請確保照片清晰且文字未被裁切。',
      );
    }
  }
}

final receiptParsingAgentProvider = Provider.autoDispose<IReceiptParsingAgent>((
  ref,
) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ReceiptParsingAgent(
    'ReceiptParsing',
    ref.watch(aiProviderProvider),
    AIAgentLogger('ReceiptParsing'),
    targetLanguage: language,
  );
});
