import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalMediaService {
  /// 儲存圖片至本地沙盒 (Application Documents Directory)，並回傳絕對路徑
  Future<String> saveImage(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/lens_wise_media');
    
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final String fileName = '${const Uuid().v4()}.jpg';
    final File file = File('${mediaDir.path}/$fileName');
    
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  /// 透過絕對路徑讀取圖片，若檔案不存在回傳 null
  Future<File?> loadImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    final file = File(imagePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// 刪除本地圖片
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    
    final paths = imagePath.split(',');
    for (final path in paths) {
      if (path.trim().isEmpty) continue;
      try {
        final file = File(path.trim());
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Failed to delete image at $path: $e');
      }
    }
  }
}
