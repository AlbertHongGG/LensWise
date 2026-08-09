import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

class ComparisonAnalysisService {
  final ProductComparisonAgent _agent;
  final ILocalStorageRepository<ComparisonRecord> _repository;
  final LocalMediaService _mediaService;

  ComparisonAnalysisService(this._agent, this._repository, this._mediaService);

  /// 執行比對解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ProductComparisonResult> analyzeAndSave(List<Uint8List> imageBytes) async {
    final result = await _agent.execute(imageBytes);

    if (result.status == 'success' && result.data != null) {
      try {
        final paths = <String>[];
        for (final img in imageBytes) {
          paths.add(await _mediaService.saveImage(img));
        }
        final imagePath = paths.join(',');
        final record = ComparisonRecord.fromAnalysisData(result.data!, imagePath: imagePath);
        await _repository.save(record.id, record);
      } catch (e) {
        print('Error saving comparison to history: $e');
      }
    }

    return result;
  }
}

final comparisonAnalysisServiceProvider = Provider<ComparisonAnalysisService>((ref) {
  return ComparisonAnalysisService(
    ref.watch(productComparisonAgentProvider),
    ref.watch(comparisonRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
