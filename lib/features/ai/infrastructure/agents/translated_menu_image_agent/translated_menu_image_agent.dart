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

class TranslatedMenuImageRequest {
  final List<Uint8List> images;
  final String targetLanguage;
  final MenuScannerRecord record;

  TranslatedMenuImageRequest({
    required this.images,
    required this.targetLanguage,
    required this.record,
  });
}

class TranslatedMenuImageAgent extends BaseAgent<TranslatedMenuImageRequest, GenerateResponse> {
  TranslatedMenuImageAgent(super.agentType, super.provider, super.logger);

  @override
  Future<GenerateResponse> execute(TranslatedMenuImageRequest input) async {
    final request = GenerateRequest(
      systemPrompt: buildTranslatedMenuImageSystemPrompt(),
      prompt: buildTranslatedMenuImageUserPrompt(input.targetLanguage, input.record),
      images: input.images,
    );

    final response = await executePrompt(request);
    
    if (response.images == null || response.images!.isEmpty) {
      throw Exception('AI 未能生成翻譯菜單圖片，請稍後再試。');
    }
    
    return response;
  }
}

final translatedMenuImageAgentProvider = Provider.autoDispose<TranslatedMenuImageAgent>((ref) {
  return TranslatedMenuImageAgent(
    AiAgentType.translatedMenuImage,
    ref.watch(aiProviderProvider),
    AIAgentLogger(AiAgentType.translatedMenuImage),
  );
});
