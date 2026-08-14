import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'prompts.dart';
import 'package:lens_wise/core/models/target_language.dart';

class MenuTranslationRequest {
  final List<Uint8List> images;
  final TargetLanguage targetLanguage;
  final MenuScannerRecord record;

  MenuTranslationRequest({
    required this.images,
    required this.targetLanguage,
    required this.record,
  });
}

class MenuTranslationAgent extends BaseAgent<MenuTranslationRequest, GenerateResponse> {
  MenuTranslationAgent(super.agentType, super.provider, super.logger);

  @override
  Future<GenerateResponse> execute(MenuTranslationRequest input) async {
    final request = GenerateRequest(
      systemPrompt: buildMenuTranslationSystemPrompt(),
      prompt: buildMenuTranslationUserPrompt(input.targetLanguage, input.record),
      images: input.images,
    );

    final response = await executePrompt(request);
    
    if (response.images == null || response.images!.isEmpty) {
      throw Exception('AI 未能生成翻譯菜單圖片，請稍後再試。');
    }
    
    return response;
  }
}

final menuTranslationAgentProvider = Provider.autoDispose<MenuTranslationAgent>((ref) {
  return MenuTranslationAgent(
    AiAgentType.menuTranslation,
    ref.watch(aiProviderFamily(AiAgentType.menuTranslation)),
    AIAgentLogger(AiAgentType.menuTranslation),
  );
});
