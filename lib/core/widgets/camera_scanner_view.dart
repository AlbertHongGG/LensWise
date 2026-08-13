import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:lens_wise/core/di/hardware_providers.dart';

class CameraScannerView extends ConsumerStatefulWidget {
  final Widget Function() customOverlayBuilder;

  const CameraScannerView({
    super.key,
    required this.customOverlayBuilder,
  });

  @override
  ConsumerState<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends ConsumerState<CameraScannerView> {

  @override
  Widget build(BuildContext context) {
    // 雙層解耦架構 (Decoupled Rendering Architecture)
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. 底層：絕對數學對齊的硬體渲染層
        Container(
          color: Colors.black, // 充當黑邊 (Letterbox) 背景
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRect( // 確保任何可能的溢出都被完美裁掉
                child: FittedBox(
                  // 關鍵 1: 使用 Flutter 絕對對稱的 cover 矩陣進行放大，確保 100% 畫面不偏移
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  // 關鍵 2: 給相機一個強制的 4:3 數學容器 (Portrait 下是 3:4)
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxWidth * (4 / 3),
                    child: CameraAwesomeBuilder.custom(
                      saveConfig: SaveConfig.photo(),
                      sensorConfig: SensorConfig.single(
                        sensor: Sensor.position(SensorPosition.back),
                        flashMode: FlashMode.none,
                        aspectRatio: CameraAspectRatios.ratio_4_3,
                        zoom: 0.0,
                      ),
                      // 關鍵 3: 既然容器已經是 3:4，這裡無論用 contain 或 cover 都不會觸發底層不對稱裁切 BUG
                      previewFit: CameraPreviewFit.cover,
                      // 完全拔除 Analysis Stream (解決嚴重 GC 效能問題與記憶體洩漏)
                      // previewFit: CameraPreviewFit.cover,
                      // 不再強制開啟背景資料流，CameraAwesome 現在只負責 ViewFinder (預覽) 與快拍。
                      builder: (cameraState, preview) {
                        // Pass hardware state to the decoupled service instead of UI
                        ref.read(cameraServiceProvider).setCameraState(cameraState);
                        return const SizedBox.shrink(); // 渲染淨空，交給外層
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 2. 表層：完全不受縮放與裁切影響的全螢幕 UI 操控層
        widget.customOverlayBuilder(),
      ],
    );
  }
}
