import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';

class RecordManagerService {
  final LocalMediaService _mediaService;

  RecordManagerService(this._mediaService);

  /// 統一刪除紀錄與關聯圖片 (Storage Coordinator Pattern)
  /// 確保實體檔案與資料庫紀錄的生命週期一致，避免 Storage Leak。
  Future<void> deleteRecord<T>({
    required ILocalStorageRepository<T> repository,
    required String id,
    String? imagePath,
  }) async {
    // 1. Delete associated media files from disk
    if (imagePath != null && imagePath.isNotEmpty) {
      await _mediaService.deleteImage(imagePath);
    }
    
    // 2. Delete database record from Hive
    await repository.delete(id);
  }
}

final recordManagerServiceProvider = Provider<RecordManagerService>((ref) {
  return RecordManagerService(ref.watch(localMediaServiceProvider));
});
