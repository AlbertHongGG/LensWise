import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'prompts.dart';

import 'package:lens_wise/features/receipt_scanner/domain/interfaces/i_receipt_scanner_agent.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';

import 'receipt_scanner_payload_parser.dart';

class ReceiptScannerAgent extends BaseAgent<List<Uint8List>, ReceiptScannerRecord> implements IReceiptScannerAgent {
  final TargetLanguage targetLanguage;

  ReceiptScannerAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Stream<StreamingSnapshot<ReceiptScannerRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(targetLanguage),
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: ReceiptScannerPayloadParser.parseStreamingSnapshot,
      initialData: ReceiptScannerRecord.empty(),
    );
  }

  @override
  Future<ReceiptScannerRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildReceiptParsingSystemPrompt(targetLanguage),
      prompt: buildReceiptParsingUserPrompt(),
      images: input,
    );

    final response = await executePrompt(request);
    final responseText = response.text;

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      final status = jsonMap['status'] as String? ?? 'error';

      if (status != 'success') {
        throw Exception(jsonMap['message']?.toString() ?? '解析過程發生錯誤');
      }

      return ReceiptScannerPayloadParser.parseStreamingSnapshot(jsonMap);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('收據解析失敗，請確保照片清晰且文字未被裁切。');
    }
  }
}

final receiptScannerAgentProvider = Provider<IReceiptScannerAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ReceiptScannerAgent(
    AiAgentType.receiptScanner,
    ref.watch(aiProviderFamily(AiAgentType.receiptScanner)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.receiptScanner)),
    targetLanguage: language,
  );
});

