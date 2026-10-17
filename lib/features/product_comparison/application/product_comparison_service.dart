import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:uuid/uuid.dart';

class ProductComparisonService {
  final Ref _ref;

  ProductComparisonService(this._ref);

  Future<ProductComparisonRecord> analyzeAndSave(List<Uint8List> imageBytes) async {
    final agent = _ref.read(productComparisonAgentProvider);
    final parsedRecord = await agent.execute(imageBytes);
    return saveCompletedRecord(parsedRecord, imageBytes);
  }

  /// 串流完成時持久化商品比對記錄與圖片
  Future<ProductComparisonRecord> saveCompletedRecord(ProductComparisonRecord parsedRecord, List<Uint8List> imageBytes) async {
    final mediaService = _ref.read(localMediaServiceProvider);
    final paths = <String>[];
    for (final img in imageBytes) {
      paths.add(await mediaService.saveImage(img));
    }
    
    final record = parsedRecord.copyWith(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      imagePaths: paths,
    );

    await _ref.read(comparisonHistoryProvider.notifier).saveRecord(record);
    return record;
  }
}

final productComparisonServiceProvider = Provider<ProductComparisonService>((ref) {
  return ProductComparisonService(ref);
});
