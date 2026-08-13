import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/errors/app_error_mapper.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class ProductProcessingPage extends ConsumerStatefulWidget {
  const ProductProcessingPage({super.key});

  @override
  ConsumerState<ProductProcessingPage> createState() => _ProductProcessingPageState();
}

class _ProductProcessingPageState extends ConsumerState<ProductProcessingPage> {
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
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: const Text('無效的資料 (返回)'),
            ),
          );
        }
        
        final record = state.result!;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pushReplacement('/product/detail', extra: {
            'record': state.result,
            'appImages': state.appImages,
          });
        });

        // 在跳轉前維持著載入畫面
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb(size: 100, isDark: isDark),
              const SizedBox(height: 32),
              const Text(
                '解析完成...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        );

      case ProductLensStatus.idle:
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
