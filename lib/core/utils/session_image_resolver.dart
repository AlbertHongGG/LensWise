import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/utils/app_paths.dart';

/// 1x1 透明 PNG 位元組，用於無圖片或極端邊界情況下的安全佔位，防止 ImageProvider 拋出異常。
final Uint8List kTransparentImageBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

/// 封裝「即時串流記憶體圖片 (Live Session)」與「歷史持久化磁碟圖片 (History Mode)」的雙軌生命週期解析器。
///
/// 核心職責：
/// 1. 隔離 UI 元件與底層圖片來源（MemoryImage vs FileImage），實現依賴倒置。
/// 2. 嚴格執行索引保護（Index Clamping），當要求索引超出圖片長度時平滑鎖定至最後一張，防止 IndexOutOfBounds。
/// 3. 提供安全 Fallback 佔位機制，當無任何圖片時永不觸發 Null check operator 或紅畫面崩潰。
/// 4. 統一透過 ResizeImage 限制解析度（預設寬度 1080px），防範大圖 OOM。
class SessionImageResolver {
  final List<AppImageEntity>? memoryImages;
  final List<String> imagePaths;

  const SessionImageResolver({
    this.memoryImages,
    this.imagePaths = const [],
  });

  /// 是否處於記憶體暫存態（即時串流分析階段）
  bool get isMemorySource => memoryImages != null && memoryImages!.isNotEmpty;

  /// 當前可用圖片總數
  int get count => isMemorySource ? memoryImages!.length : imagePaths.length;

  /// 是否包含至少一張可用圖片
  bool get hasImages => count > 0;

  /// 獲取安全快取的 ImageProvider
  ///
  /// [index]: 目標圖片索引
  /// [targetWidth]: 快取降採樣寬度，預設 1080 像素以優化記憶體使用
  ImageProvider resolve(int index, {int targetWidth = 1080}) {
    if (count == 0) {
      return ResizeImage(MemoryImage(kTransparentImageBytes), width: 1);
    }

    final safeIndex = index.clamp(0, count - 1);

    if (isMemorySource) {
      final entity = memoryImages![safeIndex];
      return ResizeImage(MemoryImage(entity.bytes), width: targetWidth);
    } else {
      final filename = imagePaths[safeIndex];
      if (filename.isEmpty) {
        return ResizeImage(MemoryImage(kTransparentImageBytes), width: 1);
      }
      return ResizeImage(FileImage(AppPaths.getImageFile(filename)), width: targetWidth);
    }
  }

  /// 取得磁碟檔案檔名（歷史模式下有效，即時模式下可能為 null）
  String? getDiskPath(int index) {
    if (imagePaths.isEmpty) return null;
    final safeIndex = index.clamp(0, imagePaths.length - 1);
    final path = imagePaths[safeIndex];
    return path.isNotEmpty ? path : null;
  }
}
