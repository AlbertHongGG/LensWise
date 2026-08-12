import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/history/domain/controllers/i_history_controller.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/product_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/receipt_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/comparison_history_tab.dart';
import 'dart:ui';

class HistoryDragData {
  final IHistoryRecord record;
  final IHistoryController controller;
  const HistoryDragData({required this.record, required this.controller});
}

class UnifiedHistoryPage extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const UnifiedHistoryPage({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<UnifiedHistoryPage> createState() => _UnifiedHistoryPageState();
}

class _UnifiedHistoryPageState extends ConsumerState<UnifiedHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IHistoryController _getCurrentController() {
    switch (_tabController.index) {
      case 0:
        return ref.read(receiptHistoryProvider.notifier);
      case 1:
        return ref.read(productHistoryProvider.notifier);
      case 2:
      default:
        return ref.read(comparisonHistoryProvider.notifier);
    }
  }

  String _getCurrentTabTitle() {
    switch (_tabController.index) {
      case 0:
        return 'CLEAR RECEIPT HISTORY';
      case 1:
        return 'CLEAR PRODUCT HISTORY';
      case 2:
      default:
        return 'CLEAR COMPARISON HISTORY';
    }
  }

  void _showClearAllDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _getCurrentController();
    final title = _getCurrentTabTitle();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SwipeToObliterateButton(
              onConfirmed: () async {
                await controller.clearAll();
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      ReceiptHistoryTab(),
                      ProductHistoryTab(),
                      ComparisonHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
            
            // Floating Trash Can Target
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: DragTarget<HistoryDragData>(
                  onAcceptWithDetails: (details) async {
                    final data = details.data;
                    await data.controller.deleteRecord(data.record);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    
                    return GestureDetector(
                      onTap: _showClearAllDrawer,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isHovering ? 64 : 56,
                        height: isHovering ? 64 : 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHovering
                              ? Colors.redAccent.withValues(alpha: 0.9)
                              : (isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8)),
                          boxShadow: [
                            BoxShadow(
                              color: isHovering ? Colors.redAccent.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
                              blurRadius: isHovering ? 20 : 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                          border: Border.all(
                            color: isHovering ? Colors.red : (isDark ? Colors.white12 : Colors.black12),
                            width: isHovering ? 2 : 1,
                          ),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Icon(
                              isHovering ? Icons.delete_forever : Icons.delete_outline,
                              color: isHovering ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                              size: isHovering ? 32 : 24,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
