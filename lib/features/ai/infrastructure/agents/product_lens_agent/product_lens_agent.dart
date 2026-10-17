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

import 'package:lens_wise/features/product_lens/domain/interfaces/i_product_lens_agent.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';

import 'product_lens_payload_parser.dart';

class ProductLensAgent extends BaseAgent<List<Uint8List>, ProductLensRecord> implements IProductLensAgent {
  final TargetLanguage targetLanguage;

  ProductLensAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

  @override
  Stream<StreamingSnapshot<ProductLensRecord>> executeStreamSnapshot(List<Uint8List> input) {
    final request = GenerateRequest(
      systemPrompt: buildProductAnalysisSystemPrompt(targetLanguage),
      prompt: buildProductAnalysisUserPrompt(),
      images: input,
    );

    return executeStreamingPipeline(
      request: request,
      mapper: ProductLensPayloadParser.parseStreamingSnapshot,
      initialData: ProductLensRecord.empty(),
    );
  }

  @override
  Future<ProductLensRecord> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductAnalysisSystemPrompt(targetLanguage),
      prompt: buildProductAnalysisUserPrompt(),
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

      return ProductLensPayloadParser.parseStreamingSnapshot(jsonMap);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('解析過程發生錯誤，可能是照片資訊太過複雜。請換個角度拍攝。');
    }
  }
}

final productLensAgentProvider = Provider<IProductLensAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductLensAgent(
    AiAgentType.productLens,
    ref.watch(aiProviderFamily(AiAgentType.productLens)),
    ref.watch(aiAgentLoggerProvider(AiAgentType.productLens)),
    targetLanguage: language,
  );
});

