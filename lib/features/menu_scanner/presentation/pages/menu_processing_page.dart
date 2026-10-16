import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/premium_error_view.dart';
import 'package:lens_wise/features/ai/presentation/widgets/thinking_orb.dart';
import 'package:lens_wise/features/menu_scanner/presentation/controllers/menu_scanner_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class MenuProcessingPage extends ConsumerStatefulWidget {
  final List<AppImageEntity> memoryImages;

  const MenuProcessingPage({super.key, required this.memoryImages});

  @override
  ConsumerState<MenuProcessingPage> createState() => _MenuProcessingPageState();
}

class _MenuProcessingPageState extends ConsumerState<MenuProcessingPage> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuScannerControllerProvider.notifier).reset();
      ref.read(menuScannerControllerProvider.notifier).analyzeMenu(widget.memoryImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MenuScannerState>(menuScannerControllerProvider, (prev, next) {
      if (next.status == MenuScannerStatus.streaming ||
          next.status == MenuScannerStatus.success) {
        if (!_hasNavigated && next.parsingResult != null) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.pushReplacement('/result/menu', extra: {
              'record': next.parsingResult,
              'memoryImages': widget.memoryImages,
            });
          });
        }
      }
    });

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
    if (state.status == MenuScannerStatus.error && state.errorMessage != null) {
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
          Text(
            state.status == MenuScannerStatus.streaming
                ? '菜單辨識完成，載入中...'
                : 'AI 菜單解析中...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.status == MenuScannerStatus.streaming
                ? '即將為您即時展開餐點明細'
                : '正在為您翻譯餐點與價格\n這可能需要幾秒鐘的時間',
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
