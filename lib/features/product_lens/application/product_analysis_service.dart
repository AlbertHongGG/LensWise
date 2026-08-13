import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/interfaces/i_product_analysis_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_repository.dart';
import 'package:uuid/uuid.dart';

class ProductAnalysisService {
  final IProductAnalysisAgent _agent;
  final IProductRepository _repository;
  final LocalMediaService _mediaService;

  ProductAnalysisService(this._agent, this._repository, this._mediaService);

  /// 執行 AI 解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductRecord> analyzeAndSave(
    List<Uint8List> imageBytesList,
  ) async {
    final result = await _agent.execute(imageBytesList);

    if (result.status != 'success' || result.data == null) {
      throw Exception(result.message ?? '解析失敗，請稍後再試');
    }

    try {
      final List<String> savedImagePaths = [];

      for (final bytes in imageBytesList) {
        final path = await _mediaService.saveImage(bytes);
        savedImagePaths.add(path);
      }

      final data = result.data!;
      final record = ProductRecord(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        productName: data.productName.isNotEmpty ? data.productName : (data.originalName.isNotEmpty ? data.originalName : '未知商品'),
        originalName: data.originalName,
        brand: data.brand,
        origin: data.origin,
        summary: data.summary,
        ingredients: data.ingredients,
        allergenAlerts: data.allergens,
        dietaryFlags: data.dietaryFlags,
        whenRecommended: data.recommendedFor,
        whenNotRecommended: data.notRecommendedFor,
        imagePaths: savedImagePaths,
      );
      await _repository.save(record.id, record);
      return record;
    } catch (e) {
      print('Error saving to history: $e');
      throw Exception('資料解析異常，請確保圖片清晰度並重新嘗試');
    }
  }
}

final productAnalysisServiceProvider = Provider<ProductAnalysisService>((ref) {
  return ProductAnalysisService(
    ref.watch(productAnalysisAgentProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
