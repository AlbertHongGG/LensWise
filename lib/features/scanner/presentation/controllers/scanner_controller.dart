import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_state.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_mode_config.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ScannerController extends Notifier<ScannerState> {
  @override
  ScannerState build() {
    return const ScannerState();
  }

  void setMode(ScannerMode mode) {
    state = state.copyWith(
      currentMode: mode,
      capturedImages: [],
      actionState: CameraActionState.idle,
    );
  }

  void onImageCaptured(Uint8List image, {ImageSourceType source = ImageSourceType.camera}) {
    if (state.hasReachedMaxShots) return;
    
    state = state.copyWith(
      capturedImages: [...state.capturedImages, AppImageEntity(bytes: image, source: source)]
    );

    if (state.config.isAutoProcess && state.hasReachedMinShots) {
      // Auto-process logic can be added here if needed
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.capturedImages.length) {
      final updatedList = List<AppImageEntity>.from(state.capturedImages)..removeAt(index);
      state = state.copyWith(capturedImages: updatedList);
    }
  }
  
  void setActionState(CameraActionState actionState) {
    state = state.copyWith(actionState: actionState);
  }

  void reset() {
    state = state.copyWith(capturedImages: [], actionState: CameraActionState.idle);
  }

  Future<void> processImages(BuildContext context) async {
    if (state.capturedImages.isEmpty) return;
    if (!state.hasReachedMinShots) return;

    setActionState(CameraActionState.analyzing);

    try {
      final processedImages = state.capturedImages.toList();
      
      // Removed physical crop logic completely! 
      // Images now retain their pristine 4:3 camera resolution or gallery original ratio.
      
      // We don't overwrite state.capturedImages since we aren't mutating them anymore.
      // state = state.copyWith(capturedImages: processedImages);

      if (context.mounted) {
        switch (state.currentMode) {
          case ScannerMode.product:
            context.push('/process/product', extra: processedImages);
            break;
          case ScannerMode.comparison:
            context.push('/process/comparison', extra: processedImages);
            break;
          case ScannerMode.receipt:
            context.push('/process/receipt', extra: processedImages);
            break;
          case ScannerMode.menu:
            context.push('/process/menu', extra: processedImages);
            break;
        }
      }
    } finally {
      setActionState(CameraActionState.idle);
      reset(); // Reset after routing
    }
  }
}

final scannerControllerProvider = NotifierProvider<ScannerController, ScannerState>(() {
  return ScannerController();
});
