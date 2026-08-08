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
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.75;
        return Stack(
          children: [
            Center(
              child: Container(
                width: boxSize,
                height: boxSize * 1.2,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.cyan.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)
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
    if (capturedImages.isEmpty) return;
    
    // 1. Trigger analysis
    ref.read(productLensControllerProvider.notifier).analyzeImage(capturedImages.first);
    
    // 2. Navigate to result page immediately
    context.push('/result/product');
  }
}
