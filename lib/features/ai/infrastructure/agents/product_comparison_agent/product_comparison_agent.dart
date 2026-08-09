import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'prompts.dart';

import 'package:lens_wise/features/ai/domain/models/product_comparison_result.dart';
import 'package:lens_wise/features/ai/domain/interfaces/i_comparison_agent.dart';

class ProductComparisonAgent extends BaseAgent<List<Uint8List>, ProductComparisonResult> implements IComparisonAgent {
  final String targetLanguage;

  ProductComparisonAgent(super.agentName, super.provider, super.logger, {required this.targetLanguage});

  @override
  Future<ProductComparisonResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductComparisonSystemPrompt(targetLanguage, input.length),
      prompt: buildProductComparisonUserPrompt(),
      images: input,
    );

    final responseText = await executePrompt(request);
    
    try {
      final jsonMap = extractJson<Map<String, dynamic>>(responseText);
      return ProductComparisonResult.fromJson(jsonMap);
    } catch (e) {
      return ProductComparisonResult(
        status: 'needs_more_info', 
        message: '解析或比對過程發生錯誤，請確認照片是否清晰且包含多樣商品。'
      );
    }
  }
}

final productComparisonAgentProvider = Provider.autoDispose<IComparisonAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductComparisonAgent(
    'ProductComparison',
    ref.watch(aiProviderProvider),
    AIAgentLogger('ProductComparison'),
    targetLanguage: language,
  );
});
