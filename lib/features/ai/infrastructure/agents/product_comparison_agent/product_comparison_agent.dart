import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'prompts.dart';

import 'package:lens_wise/features/product_comparison/domain/interfaces/i_product_comparison_agent.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_result.dart';

class _ComparisonResponseDto {
  final String status;
  final String? message;
  final Map<String, dynamic>? data; // The raw JSON payload for ProductComparisonResult

  _ComparisonResponseDto({required this.status, this.message, this.data});

  factory _ComparisonResponseDto.fromJson(Map<String, dynamic> json) {
    return _ComparisonResponseDto(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class ProductComparisonAgent extends BaseAgent<List<Uint8List>, ProductComparisonResult> implements IProductComparisonAgent {
  final String targetLanguage;

  ProductComparisonAgent(
    super.agentName,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

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
      final dto = _ComparisonResponseDto.fromJson(jsonMap);

      if (dto.status != 'success' || dto.data == null) {
        throw Exception(dto.message ?? '解析過程發生錯誤');
      }

      // Convert the AI DTO map into the true Domain Model
      return ProductComparisonResult.fromJson(dto.data!);
    } catch (e) {
      throw Exception('解析或比對過程發生錯誤，請確認照片是否清晰且包含多樣商品。');
    }
  }
}

final productComparisonAgentProvider = Provider.autoDispose<IProductComparisonAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductComparisonAgent(
    'ProductComparison',
    ref.watch(aiProviderProvider),
    AIAgentLogger('ProductComparison'),
    targetLanguage: language,
  );
});
