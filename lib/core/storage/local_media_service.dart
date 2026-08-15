import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LocalMediaService {
  /// 取得媒體儲存的基礎目錄
  Future<Directory> _getMediaDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/lens_wise_media');
    
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  /// 儲存圖片至本地沙盒，並回傳純檔名 (Filename)
  Future<String> saveImage(Uint8List imageBytes) async {
    final mediaDir = await _getMediaDir();
    final String fileName = '${const Uuid().v4()}.jpg';
    final File file = File('${mediaDir.path}/$fileName');
    
    await file.writeAsBytes(imageBytes);
    return fileName;
  }

  /// 透過檔名讀取圖片，若檔案不存在回傳 null。
  /// 警告：不再向下相容絕對路徑，若找不到檔案即回傳 null。
  Future<File?> loadImage(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return null;
    
    final mediaDir = await _getMediaDir();
    final file = File('${mediaDir.path}/$fileName');
    
    if (await file.exists()) {
      return file;
    }
    
    return null;
  }

  /// 刪除本地圖片
  /// 警告：嚴格假設傳入的字串為純檔名，不再向下相容舊版的絕對路徑。
  Future<void> deleteImage(String? fileNames) async {
    if (fileNames == null || fileNames.isEmpty) return;
    
    final paths = fileNames.split(',');
    final mediaDir = await _getMediaDir();

    for (final fileName in paths) {
      if (fileName.trim().isEmpty) continue;
      try {
        final file = File('${mediaDir.path}/${fileName.trim()}');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Failed to delete image $fileName: $e');
      }
    }
  }
}
