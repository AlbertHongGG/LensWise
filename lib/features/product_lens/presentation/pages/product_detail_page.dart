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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(), // Prevent scrolling if content fits
        child: Column(
          children: [
            // Header Image Area
            SizedBox(
              height: 240.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImmersiveBackground(
                    imageBytes: imageBytes,
                    imagePath: record.imagePath,
                  ),
                  // Persistent bottom gradient to blend smoothly into the content
                  Positioned(
                    bottom: -2,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bgColor.withValues(alpha: 0.0),
                            bgColor.withValues(alpha: 0.6),
                            bgColor,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Top Floating Close Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Area
            Container(
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  HeroTitleOverlay(
                    productName: record.productName,
                    originalName: record.originalName,
                    brand: record.brand,
                    origin: record.origin,
                  ),
                  const SizedBox(height: 16),
                  VerdictFloatingCard(summary: record.summary),
                  InteractiveDetailPanel(record: record),
                  const SizedBox(height: 48), // Padding at the very bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
