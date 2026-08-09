import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
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
    
    // 1. Trigger analysis
    ref.read(productLensControllerProvider.notifier).analyzeImage(capturedImages.value.first);
    
    // 2. Navigate to processing page immediately
    context.push('/product/processing');
  }
}
