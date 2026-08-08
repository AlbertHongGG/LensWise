import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScannerView extends StatelessWidget {
  final Widget? overlay;
  final CameraController? controller;
  final bool isInitialized;

  const CameraScannerView({
    super.key,
    this.overlay,
    this.controller,
    this.isInitialized = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller!),
        if (overlay != null) overlay!,
      ],
    );
  }
}
