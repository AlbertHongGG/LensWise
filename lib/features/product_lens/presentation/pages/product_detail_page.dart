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
      body: Stack(
        children: [
          // 1. Fixed Top Image Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: ImmersiveBackground(
              imageBytes: imageBytes,
              imagePath: record.imagePath,
            ),
          ),
          
          // (Close button removed as requested)
          
          // Right Floating Glassmorphism FABs
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: InteractiveDetailPanel(record: record),
          ),
          
          // 2. Fixed Bottom Content Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42, // Overlap the image slightly
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Area (Will take natural height, bounded by maxLines)
                  HeroTitleOverlay(
                    productName: record.productName,
                    originalName: record.originalName,
                    brand: record.brand,
                    origin: record.origin,
                  ),
                  const SizedBox(height: 24),
                  // Scrollable Summary Area (Will take remaining space)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 40), // Padding at bottom of scroll
                      child: VerdictFloatingCard(summary: record.summary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
