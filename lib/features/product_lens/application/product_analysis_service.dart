import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

class ProductAnalysisService {
  final ProductAnalysisAgent _agent;
  final ILocalStorageRepository<ProductRecord> _repository;
  final LocalMediaService _mediaService;

  ProductAnalysisService(this._agent, this._repository, this._mediaService);

  /// 執行 AI 解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductAnalysisResult> analyzeAndSave(Uint8List imageBytes) async {
    final result = await _agent.execute(imageBytes);

    if (result.status == 'success' && result.data != null) {
      try {
        final imagePath = await _mediaService.saveImage(imageBytes);
        final record = ProductRecord.fromAnalysisData(result.data!, imagePath: imagePath);
        await _repository.save(record.id, record);
      } catch (e) {
        // 這裡可以考慮加上 Logger，但不應該因為存檔失敗就阻斷使用者的畫面顯示
        print('Error saving to history: $e');
      }
    }

    return result;
  }
}

final productAnalysisServiceProvider = Provider<ProductAnalysisService>((ref) {
  return ProductAnalysisService(
    ref.watch(productAnalysisAgentProvider),
    ref.watch(productRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
