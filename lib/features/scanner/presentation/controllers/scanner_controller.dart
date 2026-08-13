import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_state.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_mode_config.dart';
import 'package:lens_wise/core/utils/image_processing_pipeline.dart';

import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';

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

  void onImageCaptured(Uint8List image) {
    if (state.hasReachedMaxShots) return;
    
    state = state.copyWith(
      capturedImages: [...state.capturedImages, image]
    );

    if (state.config.isAutoProcess && state.hasReachedMinShots) {
      // Auto-process logic can be added here if needed
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.capturedImages.length) {
      final updatedList = List<Uint8List>.from(state.capturedImages)..removeAt(index);
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
      final screenSize = MediaQuery.of(context).size;
      final screenRatio = screenSize.width / screenSize.height;
      
      final processedImages = <Uint8List>[];
      for (final bytes in state.capturedImages) {
        if (state.currentMode == ScannerMode.receipt) {
          processedImages.add(bytes);
        } else {
          final cropped = await ImageProcessingPipeline.cropToScreenRatio(bytes, screenRatio);
          processedImages.add(cropped);
        }
      }
      
      state = state.copyWith(capturedImages: processedImages);

      if (context.mounted) {
        switch (state.currentMode) {
          case ScannerMode.product:
            ref.read(productLensControllerProvider.notifier).analyzeImage(processedImages);
            context.push('/product/processing');
            break;
          case ScannerMode.comparison:
            context.push('/process/comparison', extra: processedImages);
            break;
          case ScannerMode.receipt:
            ref.read(receiptScannerControllerProvider.notifier).reset();
            context.push('/process/receipt', extra: processedImages);
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
