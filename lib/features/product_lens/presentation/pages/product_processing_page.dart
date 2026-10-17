import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/errors/app_error_mapper.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ProductProcessingPage extends ConsumerStatefulWidget {
  final List<AppImageEntity> memoryImages;

  const ProductProcessingPage({super.key, required this.memoryImages});

  @override
  ConsumerState<ProductProcessingPage> createState() => _ProductProcessingPageState();
}

class _ProductProcessingPageState extends ConsumerState<ProductProcessingPage> {
  bool _hasNavigated = false;
  late final ProductLensController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(productLensControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.reset();
      _controller.analyzeImage(widget.memoryImages);
    });
  }

  @override
  void dispose() {
    if (!_hasNavigated) {
      Future.microtask(() => _controller.reset());
    }
    super.dispose();
  }

  void _navigateToDetail(ProductLensState state) {
    if (_hasNavigated || state.result == null) return;
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacement('/result/product', extra: {
        'record': state.result,
        'memoryImages': widget.memoryImages,
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

    if (state.status == ProductLensStatus.error && state.errorMessage != null) {
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
    }

    final isStreaming = state.status == ProductLensStatus.streaming || state.status == ProductLensStatus.success;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThinkingOrb(size: 100, isDark: isDark),
          const SizedBox(height: 32),
          Text(
            isStreaming ? '特徵辨識完成，載入中...' : 'AI 連線解析中...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isStreaming
                ? '即將為您即時展開分析結果'
                : '正在為您辨識商品包裝特徵\n這可能需要幾秒鐘的時間',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
