import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/immersive_background.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/product_result_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/product_chat_adapter.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/verdict_floating_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/interactive_detail_panel.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductRecord record;
  final List<Uint8List>? imageBytesList;

  const ProductDetailPage({
    super.key,
    required this.record,
    this.imageBytesList,
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
            // 增加圖片高度確保完全覆蓋卡片頂部的 32px 圓角，避免露出缺角
            height: MediaQuery.of(context).size.height * 0.48,
            child: ImmersiveBackground(
              imageBytesList: imageBytesList,
              imagePaths: record.imagePaths,
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
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ]
              ),
              padding: const EdgeInsets.only(top: 32), // Only top padding for the whole card
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
                      clipBehavior: Clip.none, // Prevent clipping of shadows during bounce
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), // Padding inside scroll view for shadows
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
