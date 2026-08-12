import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'product_analysis_data.dart';
import 'prompts.dart';

class ProductAnalysisResult {
  final String status;
  final String? message;
  final ProductAnalysisData? data;

  ProductAnalysisResult({required this.status, this.message, this.data});

  factory ProductAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] != null
          ? ProductAnalysisData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProductAnalysisAgent
    extends BaseAgent<List<Uint8List>, ProductAnalysisResult> {
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

final productAnalysisAgentProvider = Provider.autoDispose<ProductAnalysisAgent>(
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
