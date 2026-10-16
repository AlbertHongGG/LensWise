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
  bool _hasNavigated = false;

  void _navigateToDetail(ProductLensState state) {
    if (_hasNavigated) return;
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacement('/product/detail', extra: {
        'record': state.result,
        'appImages': state.appImages,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductLensState>(productLensControllerProvider, (prev, next) {
      if (next.status == ProductLensStatus.streaming ||
          next.status == ProductLensStatus.success) {
        _navigateToDetail(next);
      }
    });

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
      case ProductLensStatus.connecting:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb(size: 100, isDark: isDark),
              const SizedBox(height: 32),
              const Text(
                'AI 連線解析中...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                '正在為您辨識商品包裝特徵\n即將為您即時展開分析結果',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
              ),
            ],
          ),
        );

      case ProductLensStatus.streaming:
      case ProductLensStatus.success:
        // Transitioning to detail page
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThinkingOrb(size: 100, isDark: isDark),
              const SizedBox(height: 32),
              const Text(
                '特徵辨識完成，載入中...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
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
              context.go('/scanner');
            }
          },
        );

      case ProductLensStatus.idle:
        return Center(
          child: ElevatedButton.icon(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/scanner');
              }
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回相機'),
          ),
        );
    }
  }
}
