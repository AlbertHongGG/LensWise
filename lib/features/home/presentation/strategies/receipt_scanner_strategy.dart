import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/utils/image_processing_pipeline.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
import 'package:lens_wise/features/home/presentation/widgets/gallery_picker_button.dart';
import 'package:lens_wise/features/home/presentation/widgets/custom_gallery_bottom_sheet.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/home/presentation/pages/captured_image_gallery_screen.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class ReceiptScannerStrategy extends ScannerModeStrategy {
  @override
  String get modeTitle => '收據掃描';

  @override
  int get minShotsRequired => 1;

  @override
  int? get maxShotsAllowed => null;

  @override
  bool get isAutoProcess => false;

  @override
  AnalysisConfig? get analysisConfig => AnalysisConfig(
        androidOptions: const AndroidAnalysisOptions.yuv420(width: 480),
        maxFramesPerSecond: 10, // 10 FPS is plenty for tracking without burning CPU
      );

  @override
  void onImageForAnalysis(dynamic image, WidgetRef ref) {
    // Pass real-time frames to the new PanoramicEngine
    ref.read(receiptScannerControllerProvider.notifier).processCameraImage(image);
  }

  @override
  Widget buildOverlay(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(receiptScannerControllerProvider);
        
        if (!state.isScanning) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '請點擊快門開始掃描，由上而下滑動手機\n(滑動到底後，再次點擊結束)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '最後一次錯誤: ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        // Showing scanning progress
        return Stack(
          children: [
            // Target Box Overlay
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.3), blurRadius: 10)
                  ]
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('保持穩定往下平移', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            // Progress Tracker
            Positioned(
              left: 20,
              top: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('掃描中...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('目前長度: ${state.stitchedHeight} px', style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildShutterButton(BuildContext context, WidgetRef ref, dynamic cameraState, Future<void> Function() defaultTakePicture) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(receiptScannerControllerProvider);
        final isScanning = state.isScanning;
        final isProcessingLocal = state.isProcessing;

        return GestureDetector(
          onTap: () async {
            if (isProcessingLocal) return;
            
            final controller = ref.read(receiptScannerControllerProvider.notifier);
            
            if (!isScanning) {
              // START scanning
              controller.startScanning();
            } else {
              // STOP scanning
              controller.stopScanning();
              controller.setProcessing(true);
              try {
                final longImage = await controller.getStitchedImage();
                if (longImage != null) {
                  onImageCaptured(longImage);
                } else {
                  if (context.mounted) {
                    final err = ref.read(receiptScannerControllerProvider).errorMessage ?? '未知的全景合併錯誤';
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('無效的掃描: $err')));
                  }
                }
              } finally {
                controller.setProcessing(false);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isScanning ? Colors.redAccent : Colors.white, width: 4),
              color: isScanning ? Colors.redAccent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.2),
            ),
            child: Center(
              child: isProcessingLocal
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Container(
                      width: isScanning ? 40 : 60,
                      height: isScanning ? 40 : 60,
                      decoration: BoxDecoration(
                        shape: isScanning ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: isScanning ? BorderRadius.circular(8) : null,
                        color: isScanning ? Colors.redAccent : Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildFloatingAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: capturedImages,
      builder: (context, images, child) {
        if (images.isEmpty) return const SizedBox.shrink();

        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(receiptScannerControllerProvider);
            if (state.isScanning) return const SizedBox.shrink(); // hide when scanning
            final isProcessingLocal = state.isProcessing;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: isProcessingLocal
                    ? null
                    : () async {
                        ref.read(receiptScannerControllerProvider.notifier).setProcessing(true);
                        try {
                          await processImage(context, ref);
                          reset();
                        } finally {
                          ref.read(receiptScannerControllerProvider.notifier).setProcessing(false);
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isProcessingLocal)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      else
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text('開始解析長圖', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget buildRightBottomAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: capturedImages,
      builder: (context, images, child) {
        if (images.isEmpty) return const SizedBox(width: 60, height: 60);

        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(receiptScannerControllerProvider);
            if (state.isScanning) return const SizedBox(width: 60, height: 60);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapturedImageGalleryScreen(strategy: this),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: ClipOval(child: Image.memory(images.last, fit: BoxFit.cover)),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        child: Text('${images.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget buildLeftBottomAction(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(receiptScannerControllerProvider);
        if (state.isScanning) return const SizedBox(width: 60, height: 60);
        final isProcessingLocal = state.isProcessing;

        return GalleryPickerButton(
          isLoading: isProcessingLocal,
          onTap: () async {
            if (isProcessingLocal) return;
            ref.read(receiptScannerControllerProvider.notifier).setProcessing(true);
            try {
              final bytesList = await showModalBottomSheet<List<Uint8List>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CustomGalleryBottomSheet(isMultiSelect: false),
              );

              if (bytesList != null && bytesList.isNotEmpty && context.mounted) {
                onImageCaptured(bytesList.first);
              }
            } finally {
              ref.read(receiptScannerControllerProvider.notifier).setProcessing(false);
            }
          },
        );
      },
    );
  }

  @override
  Future<void> processImage(BuildContext context, WidgetRef ref) async {
    if (capturedImages.value.isEmpty) return;
    
    // Instead of auto processing, the user manually taps "開始解析" to get here.
    final imageToAnalyze = capturedImages.value.last;
    
    // Process it through AI agent using the existing controller
    await ref.read(receiptScannerControllerProvider.notifier).analyzeReceipt(imageToAnalyze);

    if (context.mounted) {
      context.push('/result/receipt');
    }
  }
}


