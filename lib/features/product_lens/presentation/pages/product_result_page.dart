import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/errors/app_error_mapper.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/core/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/immersive_background.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/verdict_floating_card.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive/interactive_detail_panel.dart';

class ProductResultPage extends ConsumerStatefulWidget {
  const ProductResultPage({super.key});

  @override
  ConsumerState<ProductResultPage> createState() => _ProductResultPageState();
}

class _ProductResultPageState extends ConsumerState<ProductResultPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productLensControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ProductLensState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (state.status) {
      case ProductLensStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb(size: 100, isDark: isDark),
              const SizedBox(height: 32),
              const Text(
                'AI 深度萃取中...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                '正在為您解析成份與特徵\n這可能需要幾秒鐘的時間',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
              ),
            ],
          ),
        );

      case ProductLensStatus.error:
        return PremiumErrorView(
          title: '解析失敗',
          message: AppErrorMapper.map(state.errorMessage),
          isDark: isDark,
          onActionPressed: () {
            ref.read(productLensControllerProvider.notifier).reset();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        );

      case ProductLensStatus.success:
        if (state.result == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                ref.read(productLensControllerProvider.notifier).reset();
                if (context.canPop()) context.pop();
                else context.go('/');
              },
              child: const Text('無效的資料 (返回)'),
            ),
          );
        }
        
        final res = state.result!;
        if (res.status != 'success') {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.orangeAccent.withValues(alpha: 0.8)),
                const SizedBox(height: 16),
                Text(res.message ?? '圖片不清晰，無法識別商品。', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(productLensControllerProvider.notifier).reset();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: const Text('重新拍攝'),
                ),
              ],
            ),
          );
        }

        final data = res.data;
        if (data == null) {
          return const Center(child: Text('解析成功但無資料回傳'));
        }

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 0 & 1: Image and Gradient Background
              ImmersiveBackground(imageBytes: state.imageBytes),
              
              // Layer 2: Top Floating Close Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    ref.read(productLensControllerProvider.notifier).reset();
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
                      productName: data.productName.isNotEmpty ? data.productName : '未知商品',
                      originalName: data.originalName,
                      brand: data.brand,
                      origin: data.origin,
                    ),
                    VerdictFloatingCard(summary: data.summary),
                    InteractiveDetailPanel(data: data),
                  ],
                ),
              ),
            ],
          ),
        );

      case ProductLensStatus.idle:
      default:
        // Fallback for idle state (when user just lands on page without analysis)
        return Center(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回相機'),
          ),
        );
    }
  }

}
