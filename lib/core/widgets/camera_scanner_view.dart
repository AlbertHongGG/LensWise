import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class CameraScannerView extends StatefulWidget {
  final Widget Function(CameraState? state) customOverlayBuilder;

  const CameraScannerView({
    super.key,
    required this.customOverlayBuilder,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  CameraState? _cameraState;

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
                      builder: (cameraState, preview) {
                        // 狀態懸浮 (State Hoisting): 將底層硬體狀態傳遞給外層 UI，但絕不在此渲染任何 UI！
                        if (_cameraState != cameraState) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _cameraState = cameraState);
                          });
                        }
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
        widget.customOverlayBuilder(_cameraState),
      ],
    );
  }
}
