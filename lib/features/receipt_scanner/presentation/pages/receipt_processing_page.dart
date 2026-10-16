import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ReceiptProcessingPage extends ConsumerStatefulWidget {
  final List<AppImageEntity> memoryImages;

  const ReceiptProcessingPage({super.key, required this.memoryImages});

  @override
  ConsumerState<ReceiptProcessingPage> createState() => _ReceiptProcessingPageState();
}

class _ReceiptProcessingPageState extends ConsumerState<ReceiptProcessingPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptScannerControllerProvider.notifier).reset();
      ref.read(receiptScannerControllerProvider.notifier).analyzeReceipt(widget.memoryImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ReceiptScannerState>(receiptScannerControllerProvider, (prev, next) {
      if (next.status == ReceiptScannerStatus.streaming ||
          next.status == ReceiptScannerStatus.success) {
        if (!_hasNavigated && next.receiptRecord != null) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.pushReplacement('/result/receipt', extra: {
              'record': next.receiptRecord,
              'memoryImages': widget.memoryImages,
            });
          });
        }
      }
    });

    final state = ref.watch(receiptScannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, state, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReceiptScannerState state, bool isDark) {
    if (state.status == ReceiptScannerStatus.error && state.errorMessage != null) {
      return PremiumErrorView(
        title: '解析失敗',
        message: state.errorMessage!,
        isDark: isDark,
        onActionPressed: () {
          ref.read(receiptScannerControllerProvider.notifier).reset();
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
            state.status == ReceiptScannerStatus.streaming
                ? '收據辨識完成，載入中...'
                : 'AI 收據萃取中...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.status == ReceiptScannerStatus.streaming
                ? '即將為您即時展開消費明細與稅金'
                : '正在為您辨識品項與計算金額\n這可能需要幾秒鐘的時間',
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
