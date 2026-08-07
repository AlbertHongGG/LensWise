import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/console_ai_logger.dart';
import 'prompts.dart';

class ProductAnalysisResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  ProductAnalysisResult({required this.status, this.message, this.data});

  factory ProductAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class ProductAnalysisAgent extends BaseAgent<List<Uint8List>, ProductAnalysisResult> {
  ProductAnalysisAgent(super.agentName, super.provider, super.logger);

  @override
  Future<ProductAnalysisResult> execute(List<Uint8List> input) async {
    final request = GenerateRequest(
      systemPrompt: buildProductAnalysisSystemPrompt(),
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
        message: '解析過程發生錯誤，可能是照片資訊太過複雜。請換個角度拍攝。'
      );
    }
  }
}

final productAnalysisAgentProvider = Provider.autoDispose<ProductAnalysisAgent>((ref) {
  return ProductAnalysisAgent(
    'ProductAnalysis',
    ref.watch(aiProviderProvider),
    ref.watch(aiLoggerProvider),
  );
});
