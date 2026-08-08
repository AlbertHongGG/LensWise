import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/product_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/receipt_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/comparison_history_tab.dart';

class UnifiedHistoryPage extends StatelessWidget {
  final int initialTabIndex;

  const UnifiedHistoryPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: isDark ? Colors.white : AppColors.primary,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  splashBorderRadius: BorderRadius.circular(12),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 16),
                          SizedBox(width: 6),
                          Text('收據'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, size: 16),
                          SizedBox(width: 6),
                          Text('商品'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.compare_arrows, size: 16),
                          SizedBox(width: 6),
                          Text('比對'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ReceiptHistoryTab(),
                    ProductHistoryTab(),
                    ComparisonHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
