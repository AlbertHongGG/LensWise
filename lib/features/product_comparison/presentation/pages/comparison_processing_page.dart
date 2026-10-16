import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ComparisonProcessingPage extends ConsumerStatefulWidget {
  final List<AppImageEntity> memoryImages;

  const ComparisonProcessingPage({super.key, required this.memoryImages});

  @override
  ConsumerState<ComparisonProcessingPage> createState() => _ComparisonProcessingPageState();
}

class _ComparisonProcessingPageState extends ConsumerState<ComparisonProcessingPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productComparisonScannerControllerProvider.notifier).reset();
      ref.read(productComparisonScannerControllerProvider.notifier).analyzeComparison(widget.memoryImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductComparisonScannerState>(productComparisonScannerControllerProvider, (prev, next) {
      if (next.status == ProductComparisonStatus.streaming ||
          next.status == ProductComparisonStatus.success) {
        if (!_hasNavigated && next.parsingResult != null) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.pushReplacement('/result/comparison', extra: ProductComparisonRecordArgs(
              result: next.parsingResult!,
              rawImages: widget.memoryImages,
            ));
          });
        }
      }
    });

    final state = ref.watch(productComparisonScannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, state, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductComparisonScannerState state, bool isDark) {
    if (state.status == ProductComparisonStatus.error && state.errorMessage != null) {
      return PremiumErrorView(
        title: '比對失敗',
        message: state.errorMessage!,
        isDark: isDark,
        onActionPressed: () {
          ref.read(productComparisonScannerControllerProvider.notifier).reset();
          context.pop();
        },
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThinkingOrb(size: 100, isDark: isDark),
          const SizedBox(height: 32),
          Text(
            state.status == ProductComparisonStatus.streaming
                ? '商品比對完成，載入中...'
                : 'AI 多商品比對中...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.status == ProductComparisonStatus.streaming
                ? '即將為您即時展開規格矩陣與深度評測'
                : '正在為您交叉剖析特徵與決策維度\n這可能需要幾秒鐘的時間',
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
