import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/immersive_background.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/verdict_floating_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/interactive_detail_panel.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductRecord record;
  final Uint8List? imageBytes;

  const ProductDetailPage({
    super.key,
    required this.record,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 0 & 1: Image and Gradient Background
          ImmersiveBackground(
            imageBytes: imageBytes,
            imagePath: record.imagePath,
          ),
          
          // Layer 2: Top Floating Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),

          // Layer 3: Foreground Content positioned at the bottom
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                HeroTitleOverlay(
                  productName: record.productName,
                  originalName: record.originalName,
                  brand: record.brand,
                  origin: record.origin,
                ),
                VerdictFloatingCard(summary: record.summary),
                InteractiveDetailPanel(record: record),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
