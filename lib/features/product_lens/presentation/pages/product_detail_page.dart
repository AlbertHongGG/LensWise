import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/immersive_background.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/verdict_floating_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/interactive_detail_panel.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductLensRecord record;
  final List<AppImageEntity>? appImages;

  const ProductDetailPage({
    super.key,
    required this.record,
    this.appImages,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late final ProductLensController _controller;
  bool get isLiveSession => widget.appImages != null;

  @override
  void initState() {
    super.initState();
    if (isLiveSession) {
      _controller = ref.read(productLensControllerProvider.notifier);
    }
  }

  @override
  void dispose() {
    if (isLiveSession) {
      Future.microtask(() => _controller.reset());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA);

    // Static image resolution: appImages never change during the streaming session
    final effectiveAppImages = widget.appImages ?? (isLiveSession ? ref.read(productLensControllerProvider).appImages : null);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Fixed Top Image Area (Rendered once, isolated from stream updates)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.48,
            child: ImmersiveBackground(
              appImages: effectiveAppImages,
              imagePaths: widget.record.imagePaths,
            ),
          ),

          // Right Floating Glassmorphism FABs (Fine-grained boolean reactive island)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: InteractiveDetailPanel(
              initialRecord: widget.record,
              isLiveSession: isLiveSession,
            ),
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
                  // Title Area with Fine-Grained Reactive Selector
                  HeroTitleOverlay(
                    initialRecord: widget.record,
                    isLiveSession: isLiveSession,
                  ),
                  const SizedBox(height: 24),
                  // Scrollable Summary Area with Direct Text Updates
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: VerdictFloatingCard(
                        initialSummary: widget.record.summary,
                        isLiveSession: isLiveSession,
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
