import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/core/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonProcessingPage extends ConsumerStatefulWidget {
  final List<Uint8List> images;

  const ComparisonProcessingPage({super.key, required this.images});

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
      ref.read(productComparisonScannerControllerProvider.notifier).analyzeComparison(widget.images);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productComparisonScannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger navigation on success
    ref.listen<ProductComparisonScannerState>(productComparisonScannerControllerProvider, (previous, next) {
      if (!_hasNavigated && !next.isAnalyzing && next.parsingResult != null && next.parsingResult!.status == 'success') {
        _hasNavigated = true;
        
        final result = ComparisonResult.fromJson(next.parsingResult!.data!);
        final args = ComparisonResultArgs(result: result, rawImages: widget.images);

        // Replace the processing route with the result route
        context.pushReplacement('/result/comparison', extra: args);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, state, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductComparisonScannerState state, bool isDark) {
    if (state.errorMessage != null) {
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

    // Default to Loading state
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThinkingOrb(size: 100, isDark: isDark),
          const SizedBox(height: 32),
          const Text(
            'AI 正在天平上權衡差異...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '這可能需要幾秒鐘的時間',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
