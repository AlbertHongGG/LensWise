import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'product_analysis_data.dart';
import 'prompts.dart';

import 'package:lens_wise/features/ai/domain/interfaces/i_product_analysis_agent.dart';
import 'package:lens_wise/features/ai/domain/models/product_analysis_result.dart';

class ProductAnalysisAgent
    extends BaseAgent<List<Uint8List>, ProductAnalysisResult>
    implements IProductAnalysisAgent {
  final String targetLanguage;

  ProductAnalysisAgent(
    super.agentName,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Future<ProductAnalysisResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductAnalysisSystemPrompt(targetLanguage),
      prompt: buildProductAnalysisUserPrompt(),
      images: input,
    );

    final responseText = await executePrompt(request);

    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      return ProductAnalysisResult.fromJson(jsonMap);
    } catch (e) {
      return ProductAnalysisResult(
        status: 'needs_more_info',
        message: '解析過程發生錯誤，可能是照片資訊太過複雜。請換個角度拍攝。',
      );
    }
  }
}

final productAnalysisAgentProvider = Provider.autoDispose<IProductAnalysisAgent>(
  (ref) {
    final language = ref.watch(settingsProvider).targetLanguage;
    return ProductAnalysisAgent(
      'ProductAnalysis',
      ref.watch(aiProviderProvider),
      AIAgentLogger('ProductAnalysis'),
      targetLanguage: language,
    );
  },
);
