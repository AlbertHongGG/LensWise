import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = capturedImages.length;
        
        return Stack(
          children: [
            // No bounding box, just full screen
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    '商品比對',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      count < 1 
                          ? '請拍攝「第一樣」商品'
                          : '已拍攝 $count 樣商品，\n請繼續拍攝或點擊「開始比對」',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> processImage(BuildContext context, WidgetRef ref) async {
    if (capturedImages.length < minShotsRequired) return;
    context.push('/result/comparison');
  }
}
