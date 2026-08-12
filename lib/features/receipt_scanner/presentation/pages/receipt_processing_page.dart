import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';

class ReceiptProcessingPage extends ConsumerStatefulWidget {
  final List<Uint8List> images;

  const ReceiptProcessingPage({super.key, required this.images});

  @override
  ConsumerState<ReceiptProcessingPage> createState() => _ReceiptProcessingPageState();
}

class _ReceiptProcessingPageState extends ConsumerState<ReceiptProcessingPage> {
  // Navigation is decoupled to controller

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptScannerControllerProvider.notifier).reset();
      ref.read(receiptScannerControllerProvider.notifier).analyzeReceipt(widget.images);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Navigation is now completely handled by the Controller and NavigationService.
    // UI strictly acts as a dumb renderer for the loading/error state.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, state, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ReceiptScannerState state, bool isDark) {
    if (state.errorMessage != null) {
      return PremiumErrorView(
        title: '�??失�?',
        message: state.errorMessage!,
        isDark: isDark,
        onActionPressed: () {
          ref.read(receiptScannerControllerProvider.notifier).reset();
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
            'AI �?���???��??�容...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            '?�可?��?要幾秒�??��???,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
