import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/domain/interfaces/i_product_comparison_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_product_comparison_repository.dart';
import 'package:uuid/uuid.dart';

class ProductComparisonService {
  final IProductComparisonAgent _agent;
  final IProductComparisonRepository _repository;
  final LocalMediaService _mediaService;

  ProductComparisonService(this._agent, this._repository, this._mediaService);

  /// 執行比對解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductComparisonRecord> analyzeAndSave(List<Uint8List> imageBytes) async {
    // 1. Call Port (Interface) to get Domain Entity (Parsed Data)
    final parsedRecord = await _agent.execute(imageBytes);

    try {
      // 2. Orchestrate saving images
      final paths = <String>[];
      for (final img in imageBytes) {
        paths.add(await _mediaService.saveImage(img));
      }
      final imagePath = paths.join(',');
      
      // 3. Hydrate the Domain Entity wrapper with Application Context
      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePath: imagePath,
      );

      // 4. Save via Repository Port
      await _repository.save(record.id, record);
      
      return record;
    } catch (e) {
      throw Exception('資料儲存異常');
    }
  }
}

final productComparisonServiceProvider = Provider<ProductComparisonService>((ref) {
  return ProductComparisonService(
    ref.watch(productComparisonAgentProvider),
    ref.watch(productComparisonRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
