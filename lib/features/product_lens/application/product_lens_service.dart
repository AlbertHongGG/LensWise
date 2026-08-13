import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/domain/interfaces/i_product_lens_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_lens_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_lens_repository.dart';
import 'package:uuid/uuid.dart';

class ProductLensService {
  final IProductLensAgent _agent;
  final IProductLensRepository _repository;
  final LocalMediaService _mediaService;

  ProductLensService(this._agent, this._repository, this._mediaService);

  /// 執行 AI 解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductLensRecord> analyzeAndSave(
    List<Uint8List> imageBytesList,
  ) async {
    final parsedRecord = await _agent.execute(imageBytesList);

    try {
      final List<String> savedImagePaths = [];
      for (final bytes in imageBytesList) {
        final path = await _mediaService.saveImage(bytes);
        savedImagePaths.add(path);
      }

      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePaths: savedImagePaths,
      );

      await _repository.save(record.id, record);
      
      return record;
    } catch (e) {
      throw Exception('資料解析異常，請確保圖片清晰度並重新嘗試');
    }
  }
}

final productLensServiceProvider = Provider<ProductLensService>((ref) {
  return ProductLensService(
    ref.watch(productLensAgentProvider),
    ref.watch(productLensRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
