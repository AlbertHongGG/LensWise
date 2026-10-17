import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'prompts.dart';

import 'menu_scanner_payload_parser.dart';

abstract class IMenuScannerAgent {
  Future<MenuScannerRecord> execute(List<Uint8List> input);
  Stream<StreamingSnapshot<MenuScannerRecord>> executeStreamSnapshot(List<Uint8List> input);
}

class MenuScannerAgent extends BaseAgent<List<Uint8List>, MenuScannerRecord> implements IMenuScannerAgent {
  final TargetLanguage targetLanguage;

  MenuScannerAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Stream<StreamingSnapshot<MenuScannerRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildMenuScannerSystemPrompt(targetLanguage),
      prompt: buildMenuScannerUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: MenuScannerPayloadParser.parseStreamingSnapshot,
      initialData: MenuScannerRecord.empty(),
    );
  }

  @override
  Future<MenuScannerRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildMenuScannerSystemPrompt(targetLanguage),
      prompt: buildMenuScannerUserPrompt(),
      images: input,
    );

    final response = await executePrompt(request);
    final responseText = response.text;

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      return MenuScannerPayloadParser.parseFinalResponse(jsonMap);
    } catch (e, stack) {
      print('Failed to parse AI response: $e\n$stack');
      throw Exception('解析或比對過程發生錯誤: $e\n請確認照片是否清晰且包含菜單。');
    }
  }
}

final menuScannerAgentProvider = Provider<IMenuScannerAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return MenuScannerAgent(
    AiAgentType.menuScanner,
    ref.watch(aiProviderFamily(AiAgentType.menuScanner)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.menuScanner)),
    targetLanguage: language,
  );
});
