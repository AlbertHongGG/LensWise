import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/domain/interfaces/i_product_analysis_agent.dart';
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
    // 1. Call Port (Interface) to get Domain Entity (Parsed Data)
    final parsedRecord = await _agent.execute(imageBytesList);

    try {
      // 2. Orchestrate saving images
      final List<String> savedImagePaths = [];
      for (final bytes in imageBytesList) {
        final path = await _mediaService.saveImage(bytes);
        savedImagePaths.add(path);
      }

      // 3. Hydrate the Domain Entity with Application Context (ID, Timestamp, Paths)
      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePaths: savedImagePaths,
      );

      // 4. Save via Repository Port
      await _repository.save(record.id, record);
      
      return record;
    } catch (e) {
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
