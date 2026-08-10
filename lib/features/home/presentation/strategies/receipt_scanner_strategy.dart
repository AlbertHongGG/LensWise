import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/utils/image_processing_pipeline.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
import 'package:lens_wise/features/home/presentation/widgets/gallery_picker_button.dart';
import 'package:lens_wise/features/home/presentation/widgets/custom_gallery_bottom_sheet.dart';

class ReceiptScannerStrategy extends ScannerModeStrategy {
  @override
  String get modeTitle => '收據';

  @override
  Widget buildOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: SizedBox(
                width: constraints.maxWidth * 0.8,
                height: constraints.maxHeight * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
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
  Future<void> processImage(BuildContext context, WidgetRef ref) async {
    if (capturedImages.value.isEmpty) return;
    
    final screenSize = MediaQuery.of(context).size;
    final screenRatio = screenSize.width / screenSize.height;
    final cropped = await ImageProcessingPipeline.cropToScreenRatio(capturedImages.value.first, screenRatio);
    capturedImages.value = [cropped];

    if (context.mounted) {
      context.push('/result/receipt');
    }
  }

  @override
  Widget buildLeftBottomAction(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<bool>(
      valueListenable: isProcessing,
      builder: (context, loading, child) {
        return GalleryPickerButton(
          isLoading: loading,
          onTap: () async {
            if (isProcessing.value) return;
            isProcessing.value = true;
            try {
              final bytesList = await showModalBottomSheet<List<Uint8List>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CustomGalleryBottomSheet(isMultiSelect: false),
              );

              if (bytesList != null && bytesList.isNotEmpty && context.mounted) {
                onImageCaptured(bytesList.first);
                await processImage(context, ref);
                reset();
              }
            } finally {
              isProcessing.value = false;
            }
          },
        );
      },
    );
  }
}
