import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/base_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/provider_factory.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'prompts.dart';

import 'package:lens_wise/features/product_lens/domain/interfaces/i_product_lens_agent.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

class _ProductLensResponseDto {
  final String status;
  final String? message;
  final _ProductLensDataDto? data;

  _ProductLensResponseDto({required this.status, this.message, this.data});

  factory _ProductLensResponseDto.fromJson(Map<String, dynamic> json) {
    return _ProductLensResponseDto(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] != null ? _ProductLensDataDto.fromJson(json['data']) : null,
    );
  }
}

class _ProductLensDataDto {
  final String productName;
  final String originalName;
  final String brand;
  final String origin;
  final String summary;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> dietaryFlags;
  final List<String> recommendedFor;
  final List<String> notRecommendedFor;

  _ProductLensDataDto.fromJson(Map<String, dynamic> json)
      : productName = json['productName'] as String? ?? '',
        originalName = json['originalName'] as String? ?? '',
        brand = json['brand'] as String? ?? '',
        origin = json['origin'] as String? ?? '',
        summary = json['summary'] as String? ?? '',
        ingredients = (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        allergens = (json['allergens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        dietaryFlags = (json['dietaryFlags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        recommendedFor = (json['recommendedFor'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        notRecommendedFor = (json['notRecommendedFor'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
}

class ProductLensAgent extends BaseAgent<List<Uint8List>, ProductLensRecord> implements IProductLensAgent {
  final String targetLanguage;

  ProductLensAgent(
    super.agentName,
    super.provider,
    super.logger, {
    required this.targetLanguage,
  });

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
      final dto = _ProductLensResponseDto.fromJson(jsonMap);

      if (dto.status != 'success' || dto.data == null) {
        throw Exception(dto.message ?? '解析過程發生錯誤');
      }

      final data = dto.data!;
      return ProductLensRecord(
        id: '', // Placeholder, populated by Service
        timestamp: DateTime.now(), // Placeholder, populated by Service
        productName: data.productName,
        originalName: data.originalName,
        brand: data.brand,
        origin: data.origin,
        summary: data.summary,
        ingredients: data.ingredients,
        allergenAlerts: data.allergens,
        dietaryFlags: data.dietaryFlags,
        whenRecommended: data.recommendedFor,
        whenNotRecommended: data.notRecommendedFor,
        imagePaths: [], // Placeholder, populated by Service
      );
    } catch (e) {
      throw Exception('解析過程發生錯誤，可能是照片資訊太過複雜。請換個角度拍攝。');
    }
  }
}

final productLensAgentProvider = Provider.autoDispose<IProductLensAgent>((ref) {
  final language = ref.watch(settingsProvider).targetLanguage;
  return ProductLensAgent(
    'ProductLens',
    ref.watch(aiProviderProvider),
    AIAgentLogger('ProductLens'),
    targetLanguage: language,
  );
});
