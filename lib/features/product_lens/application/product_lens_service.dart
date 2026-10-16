import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/domain/interfaces/i_product_lens_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_lens_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:uuid/uuid.dart';

class ProductLensService {
  final Ref _ref;

  ProductLensService(this._ref);

  /// 執行 AI 解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductLensRecord> analyzeAndSave(
    List<Uint8List> imageBytesList,
  ) async {
    final agent = _ref.read(productLensAgentProvider);
    final mediaService = _ref.read(localMediaServiceProvider);
    
    final parsedRecord = await agent.execute(imageBytesList);

    try {
      final List<String> savedImagePaths = [];
      for (final bytes in imageBytesList) {
        final path = await mediaService.saveImage(bytes);
        savedImagePaths.add(path);
      }

      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePaths: savedImagePaths,
      );

      // Save via Controller (SSOT)
      await _ref.read(productHistoryProvider.notifier).saveRecord(record);
      
      return record;
    } catch (e) {
      throw Exception('資料解析異常，請確保圖片清晰度並重新嘗試');
    }
  }

  /// 將串流已解析完成的記錄儲存至歷史資料庫與本機檔案 (用於方案 B 串流結束時持久化)
  Future<ProductLensRecord> saveCompletedRecord(
    ProductLensRecord parsedRecord,
    List<Uint8List> imageBytesList,
  ) async {
    final mediaService = _ref.read(localMediaServiceProvider);
    final List<String> savedImagePaths = [];
    for (final bytes in imageBytesList) {
      final path = await mediaService.saveImage(bytes);
      savedImagePaths.add(path);
    }

    final record = parsedRecord.copyWith(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      imagePaths: savedImagePaths,
    );

    await _ref.read(productHistoryProvider.notifier).saveRecord(record);
    return record;
  }
}

final productLensServiceProvider = Provider<ProductLensService>((ref) {
  return ProductLensService(ref);
});
