import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/domain/interfaces/i_product_comparison_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:uuid/uuid.dart';

class ProductComparisonService {
  final Ref _ref;

  ProductComparisonService(this._ref);

  /// 執行比對解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductComparisonRecord> analyzeAndSave(List<Uint8List> imageBytes) async {
    final agent = _ref.read(productComparisonAgentProvider);
    final mediaService = _ref.read(localMediaServiceProvider);
    
    // 1. Call Port (Interface) to get Domain Entity (Parsed Data)
    final parsedRecord = await agent.execute(imageBytes);

    try {
      // 2. Orchestrate saving images
      final paths = <String>[];
      for (final img in imageBytes) {
        paths.add(await mediaService.saveImage(img));
      }
      final imagePath = paths.join(',');
      
      // 3. Hydrate the Domain Entity wrapper with Application Context
      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePath: imagePath,
      );

      // 4. Save via Controller (SSOT)
      await _ref.read(comparisonHistoryProvider.notifier).saveRecord(record);
      
      return record;
    } catch (e) {
      throw Exception('資料儲存異常');
    }
  }
}

final productComparisonServiceProvider = Provider<ProductComparisonService>((ref) {
  return ProductComparisonService(ref);
});
