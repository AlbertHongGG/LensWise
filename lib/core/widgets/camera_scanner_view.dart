import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class CameraScannerView extends StatelessWidget {
  final Widget Function(CameraState state)? customOverlayBuilder;

  const CameraScannerView({
    super.key,
    this.customOverlayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      saveConfig: SaveConfig.photo(),
      sensorConfig: SensorConfig.single(
        sensor: Sensor.position(SensorPosition.back),
        flashMode: FlashMode.none,
        aspectRatio: CameraAspectRatios.ratio_16_9,
        zoom: 0.0,
      ),
      // Root Cause Fix: camerawesome natively uses PlatformView, entirely bypassing Flutter Texture
      previewFit: CameraPreviewFit.cover,
      builder: (cameraState, preview) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (customOverlayBuilder != null) customOverlayBuilder!(cameraState),
          ],
        );
      },
    );
  }
}
