import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_agent.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';

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

    // 4. 透過 Controller 更新狀態並寫入 Repository (SSOT)
    await _ref.read(menuHistoryProvider.notifier).saveRecord(completeRecord);

    return completeRecord;
  }

  /// 串流完成時持久化菜單記錄與圖片
  Future<MenuScannerRecord> saveCompletedRecord(MenuScannerRecord parsedRecord, List<Uint8List> images) async {
    final localMediaService = _ref.read(localMediaServiceProvider);
    final savedPaths = <String>[];
    for (final imageBytes in images) {
      final path = await localMediaService.saveImage(imageBytes);
      savedPaths.add(path);
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final completeRecord = parsedRecord.copyWith(
      id: 'menu_$id',
      timestamp: DateTime.now(),
      imagePaths: savedPaths,
    );

    await _ref.read(menuHistoryProvider.notifier).saveRecord(completeRecord);
    return completeRecord;
  }

  Future<MenuScannerRecord> saveTranslatedImage(MenuScannerRecord record, String originalImagePath, AIImageResponse generatedImage) async {
    final localMediaService = _ref.read(localMediaServiceProvider);
    
    Uint8List translatedImageBytes;
    if (generatedImage is AIUrlImageResponse) {
      final res = await http.get(Uri.parse(generatedImage.url));
      if (res.statusCode == 200) {
        translatedImageBytes = res.bodyBytes;
      } else {
        throw Exception('無法下載翻譯圖片 (HTTP ${res.statusCode})');
      }
    } else if (generatedImage is AIBase64ImageResponse) {
      translatedImageBytes = base64Decode(generatedImage.base64String);
    } else if (generatedImage is AIBytesImageResponse) {
      translatedImageBytes = generatedImage.bytes;
    } else {
      throw UnimplementedError('未知的圖片格式');
    }

    // Save image
    final savedPath = await localMediaService.saveImage(translatedImageBytes);
    
    // Update map
    final newMap = Map<String, String>.from(record.translatedImagePaths);
    newMap[originalImagePath] = savedPath;
    
    final updatedRecord = record.copyWith(translatedImagePaths: newMap);
    
    // Write back to repo via Controller
    await _ref.read(menuHistoryProvider.notifier).saveRecord(updatedRecord);
    
    return updatedRecord;
  }
}

final menuScannerServiceProvider = Provider<MenuScannerService>((ref) {
  return MenuScannerService(ref);
});
