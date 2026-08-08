import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final String? error;

  CameraState({
    this.controller,
    this.isInitialized = false,
    this.error,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    String? error,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}

class CameraControllerNotifier extends Notifier<CameraState> {
  @override
  CameraState build() {
    ref.onDispose(() {
      state.controller?.dispose();
    });
    return CameraState();
  }

  Future<void> initializeCamera() async {
    if (state.isInitialized && state.controller != null) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(error: 'No cameras found');
        return;
      }

      // Root Cause Fix for Mali GPU Overheating:
      // 1. Set ResolutionPreset to medium (720p is plenty for AI scanning, reduces heat drastically vs max)
      // 2. Explicitly specify ImageFormatGroup.yuv420 to prevent OpenGL dataspace conversion churn on Android
      final controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, 
      );

      await controller.initialize();
      
      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        error: null,
      );
    } catch (e) {
      debugPrint('[ERROR] Camera init failed: $e');
      state = state.copyWith(error: e.toString());
    }
  }

}

final cameraControllerProvider = NotifierProvider<CameraControllerNotifier, CameraState>(
  () => CameraControllerNotifier(),
);
