import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppPaths {
  static late final String _mediaDirPath;

  /// 必須在 runApp 之前呼叫初始化
  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${directory.path}/lens_wise_media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    _mediaDirPath = mediaDir.path;
  }

  /// 取得媒體儲存目錄的絕對路徑
  static String get mediaDir => _mediaDirPath;

  /// 將資料庫中的檔名轉換為絕對路徑的 File 物件
  /// 警告：此方法嚴格假設傳入的字串為純檔名。不再向下相容舊版的絕對路徑。
  static File getImageFile(String filename) {
    return File('$_mediaDirPath/$filename');
  }
}
