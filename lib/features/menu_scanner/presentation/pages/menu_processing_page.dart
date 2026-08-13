import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/menu_scanner/presentation/controllers/menu_scanner_controller.dart';

class MenuProcessingPage extends ConsumerStatefulWidget {
  final List<Uint8List> images;

  const MenuProcessingPage({super.key, required this.images});

  @override
  ConsumerState<MenuProcessingPage> createState() => _MenuProcessingPageState();
}

class _MenuProcessingPageState extends ConsumerState<MenuProcessingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuScannerControllerProvider.notifier).reset();
      ref.read(menuScannerControllerProvider.notifier).analyzeMenu(widget.images);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuScannerControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context, state, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MenuScannerState state, bool isDark) {
    if (state.errorMessage != null) {
      return PremiumErrorView(
        title: '解析失敗',
        message: state.errorMessage!,
        isDark: isDark,
        onActionPressed: () {
          ref.read(menuScannerControllerProvider.notifier).reset();
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
          const Text(
            'AI 正在翻譯菜單...',
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
