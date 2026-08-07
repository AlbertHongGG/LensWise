import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/console_ai_logger.dart';
import 'prompts.dart';

class ProductComparisonResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  ProductComparisonResult({required this.status, this.message, this.data});

  factory ProductComparisonResult.fromJson(Map<String, dynamic> json) {
    return ProductComparisonResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class ProductComparisonAgent extends BaseAgent<List<Uint8List>, ProductComparisonResult> {
  ProductComparisonAgent(super.agentName, super.provider, super.logger);

  @override
  Future<ProductComparisonResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductComparisonSystemPrompt(),
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

final productComparisonAgentProvider = Provider.autoDispose<ProductComparisonAgent>((ref) {
  return ProductComparisonAgent(
    'ProductComparison',
    ref.watch(aiProviderProvider),
    ref.watch(aiLoggerProvider),
  );
});
