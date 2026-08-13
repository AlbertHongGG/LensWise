import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_agent.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

class MenuScannerService {
  final Ref _ref;

  MenuScannerService(this._ref);

  Future<MenuScannerRecord> analyzeAndSave(List<Uint8List> images) async {
    // 1. 調用 AI Agent 分析圖片
    final agent = _ref.read(menuScannerAgentProvider);
    final result = await agent.execute(images);

    // 2. 儲存原始圖片到設備存儲
    final localMediaService = _ref.read(localMediaServiceProvider);
    final savedPaths = <String>[];
    for (final imageBytes in images) {
      final path = await localMediaService.saveImage(imageBytes);
      savedPaths.add(path);
    }

    // 3. 組合完整的 Record，賦予 ID (使用儲存第一張圖片的回傳路徑或時間戳做唯一識別)
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final completeRecord = result.copyWith(
      id: 'menu_$id',
      imagePaths: savedPaths,
    );

    // 4. 寫入 Hive Repository
    final repo = _ref.read(menuScannerRepositoryProvider);
    await repo.save('menu_$id', completeRecord);

    return completeRecord;
  }
}

final menuScannerServiceProvider = Provider<MenuScannerService>((ref) {
  return MenuScannerService(ref);
});
