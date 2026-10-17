import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'prompts.dart';

import 'package:lens_wise/features/product_comparison/domain/interfaces/i_product_comparison_agent.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'product_comparison_payload_parser.dart';

class ProductComparisonAgent extends BaseAgent<List<Uint8List>, ProductComparisonRecord> implements IProductComparisonAgent {
  final TargetLanguage targetLanguage;

  ProductComparisonAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Stream<StreamingSnapshot<ProductComparisonRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildProductComparisonSystemPrompt(targetLanguage, input.length),
      prompt: buildProductComparisonUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: ProductComparisonPayloadParser.parseStreamingSnapshot,
      initialData: ProductComparisonRecord.empty(),
    );
  }

  @override
  Future<ProductComparisonRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductComparisonSystemPrompt(targetLanguage, input.length),
      prompt: buildProductComparisonUserPrompt(),
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

      return ProductComparisonPayloadParser.parseStreamingSnapshot(jsonMap);
    } catch (e, stack) {
      if (e is Exception) rethrow;
      print('Failed to parse AI response: $e\n$stack');
      throw Exception('解析或比對過程發生錯誤: $e\n請確認照片是否清晰且包含多樣商品。');
    }
  }
}

final productComparisonAgentProvider = Provider<IProductComparisonAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductComparisonAgent(
    AiAgentType.productComparison,
    ref.watch(aiProviderFamily(AiAgentType.productComparison)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.productComparison)),
    targetLanguage: language,
  );
});
