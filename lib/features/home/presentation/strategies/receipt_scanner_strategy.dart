import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';

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
    if (capturedImages.isEmpty) return;
    context.push('/result/receipt');
  }
}
