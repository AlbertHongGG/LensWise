import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/immersive_background.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/verdict_floating_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/interactive_detail_panel.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class ProductDetailPage extends ConsumerWidget {
  final ProductLensRecord record;
  final List<AppImageEntity>? appImages;

  const ProductDetailPage({
    super.key,
    required this.record,
    this.appImages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);

    // Watch streaming controller if it is actively streaming
    final controllerState = ref.watch(productLensControllerProvider);
    final isStreaming = controllerState.status == ProductLensStatus.streaming;
    final activeRecord = (isStreaming && controllerState.result != null)
        ? controllerState.result!
        : (controllerState.status == ProductLensStatus.success && controllerState.result != null)
            ? controllerState.result!
            : record;

    final effectiveAppImages = appImages ?? controllerState.appImages;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Fixed Top Image Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.48,
            child: ImmersiveBackground(
              appImages: effectiveAppImages,
              imagePaths: activeRecord.imagePaths,
            ),
          ),
          
          // Right Floating Glassmorphism FABs
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: InteractiveDetailPanel(record: activeRecord),
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
                ],
              ),
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Area with Skeleton & progressive update
                  HeroTitleOverlay(
                    productName: activeRecord.productName,
                    originalName: activeRecord.originalName,
                    brand: activeRecord.brand,
                    origin: activeRecord.origin,
                  ),
                  const SizedBox(height: 24),
                  // Scrollable Summary Area with live streaming text
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: VerdictFloatingCard(
                        summary: activeRecord.summary,
                        isStreaming: isStreaming,
                      ),
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
