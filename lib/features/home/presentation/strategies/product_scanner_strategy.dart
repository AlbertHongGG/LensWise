import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/utils/image_processing_pipeline.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
import 'package:lens_wise/features/home/presentation/widgets/gallery_picker_button.dart';
import 'package:lens_wise/features/home/presentation/widgets/custom_gallery_bottom_sheet.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class ProductScannerStrategy extends ScannerModeStrategy {
  @override
  String get modeTitle => '商品';

  @override
  Widget buildOverlay(BuildContext context) {
    return const SizedBox.shrink(); // No borders or boxes, full screen immersion
  }

  @override
  Future<void> processImage(BuildContext context, WidgetRef ref) async {
    if (capturedImages.value.isEmpty) return;
    
    final screenSize = MediaQuery.of(context).size;
    final screenRatio = screenSize.width / screenSize.height;
    final cropped = await ImageProcessingPipeline.cropToScreenRatio(capturedImages.value.first, screenRatio);

    // 1. Trigger analysis with strictly WYSIWYG image
    ref.read(productLensControllerProvider.notifier).analyzeImage(cropped);
    
    // 2. Navigate to processing page immediately
    if (context.mounted) {
      context.push('/product/processing');
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
