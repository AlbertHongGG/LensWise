import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/utils/image_processing_pipeline.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
import 'package:lens_wise/features/home/presentation/pages/captured_image_gallery_screen.dart';
import 'package:lens_wise/features/home/presentation/widgets/gallery_picker_button.dart';
import 'package:lens_wise/features/home/presentation/widgets/custom_gallery_bottom_sheet.dart';

class ComparisonScannerStrategy extends ScannerModeStrategy {
  @override
  String get modeTitle => '比對';

  @override
  int get minShotsRequired => 2;

  @override
  int? get maxShotsAllowed => null;

  @override
  bool get isAutoProcess => false;

  @override
  Widget buildOverlay(BuildContext context) {
    // 徹底清除文字雜訊，還給使用者全螢幕的取景空間
    return const SizedBox.shrink();
  }

  @override
  Widget buildFloatingAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: capturedImages,
      builder: (context, images, child) {
        if (images.length < minShotsRequired) return const SizedBox.shrink();

        return ValueListenableBuilder<CameraActionState>(
          valueListenable: actionState,
          builder: (context, state, child) {
            final locked = state != CameraActionState.idle;
            final isAnalyzing = state == CameraActionState.analyzing;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GestureDetector(
                onTap: locked
                    ? null
                    : () async {
                        actionState.value = CameraActionState.analyzing;
                        try {
                          await processImage(context, ref);
                          reset();
                        } finally {
                          actionState.value = CameraActionState.idle;
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAnalyzing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.compare, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '開始比對',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildRightBottomAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<List<Uint8List>>(
      valueListenable: capturedImages,
      builder: (context, images, child) {
        if (images.isEmpty) {
          return const SizedBox(width: 60, height: 60);
        }

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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.memory(
                        images.last,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildLeftBottomAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<CameraActionState>(
      valueListenable: actionState,
      builder: (context, state, child) {
        final locked = state != CameraActionState.idle;
        final isPicking = state == CameraActionState.pickingGallery;

        return GalleryPickerButton(
          isLoading: isPicking,
          onTap: locked ? null : () async {
            actionState.value = CameraActionState.pickingGallery;
            try {
              final bytesList = await showModalBottomSheet<List<Uint8List>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CustomGalleryBottomSheet(isMultiSelect: true, maxItems: 2),
              );

              if (bytesList != null && bytesList.isNotEmpty && context.mounted) {
                for (final b in bytesList) {
                  onImageCaptured(b);
                }
              }
            } finally {
              actionState.value = CameraActionState.idle;
            }
          },
        );
      },
    );
  }

  @override
  Future<void> processImage(BuildContext context, WidgetRef ref) async {
    if (capturedImages.value.length < minShotsRequired) return;
    
    // Phase 41: 延遲物理裁切 (Deferred Physical Crop)
    // 將耗時的裁切運算移至此處，使用者在等待 AI 時進行背景批次裁切
    final screenSize = MediaQuery.of(context).size;
    final screenRatio = screenSize.width / screenSize.height;

    final croppedImages = <Uint8List>[];
    for (final bytes in capturedImages.value) {
      final cropped = await ImageProcessingPipeline.cropToScreenRatio(bytes, screenRatio);
      croppedImages.add(cropped);
    }
    
    // 替換為真實 WYSIWYG 裁切後的圖片
    capturedImages.value = croppedImages;

    if (context.mounted) {
      context.push('/process/comparison', extra: croppedImages);
    }
  }
}
