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

import 'package:lens_wise/features/product_comparison/domain/interfaces/i_product_comparison_agent.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

class _ComparisonResponseDto {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  _ComparisonResponseDto({required this.status, this.message, this.data});

  factory _ComparisonResponseDto.fromJson(Map<String, dynamic> json) {
    return _ComparisonResponseDto(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class ProductComparisonAgent extends BaseAgent<List<Uint8List>, ProductComparisonRecord> implements IProductComparisonAgent {
  final TargetLanguage targetLanguage;

  ProductComparisonAgent(
    super.agentType,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

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
      final dto = _ComparisonResponseDto.fromJson(jsonMap);

      if (dto.status != 'success' || dto.data == null) {
        throw Exception(dto.message ?? '解析過程發生錯誤');
      }

      // Convert the AI DTO map into the true Domain Model
      return ProductComparisonRecord(
        id: '',
        timestamp: DateTime.now(),
        imagePath: '',
        title: dto.data!['title'] as String? ?? '商品比對結果',
        summary: dto.data!['summary'] as String? ?? '',
        products: (dto.data!['products'] as List<dynamic>?)
                ?.map((e) => ComparisonProduct.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        comparisonPoints: (dto.data!['comparisonPoints'] as List<dynamic>?)
                ?.map((e) => ComparisonPoint.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e, stack) {
      print('Failed to parse AI response: $e\n$stack');
      throw Exception('解析或比對過程發生錯誤: $e\n請確認照片是否清晰且包含多樣商品。');
    }
  }
}

final productComparisonAgentProvider = Provider.autoDispose<IProductComparisonAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductComparisonAgent(
    AiAgentType.productComparison,
    ref.watch(aiProviderFamily(AiAgentType.productComparison)),
    AIAgentLogger(AiAgentType.productComparison),
    targetLanguage: language,
  );
});
