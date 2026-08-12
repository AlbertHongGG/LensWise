import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/record_manager_service.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/product_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/receipt_history_tab.dart';
import 'package:lens_wise/features/history/presentation/pages/tabs/comparison_history_tab.dart';
import 'dart:ui';

enum HistoryType { receipt, product, comparison }

class HistoryDragData {
  final String id;
  final String? imagePath;
  final List<String>? imagePaths;
  final HistoryType type;
  const HistoryDragData({required this.id, this.imagePath, this.imagePaths, required this.type});
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showClearAllDrawer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTab = _tabController.index;
    
    String title = '';
    Future<void> Function()? onSwipe;
    
    if (currentTab == 0) {
      title = 'CLEAR RECEIPT HISTORY';
      onSwipe = () async {
        final repo = ref.read(receiptRepositoryProvider);
        final manager = ref.read(recordManagerServiceProvider);
        final records = await repo.getAll();
        for (final r in records) {
          await manager.deleteRecord(repository: repo, id: r.id, imagePaths: r.imagePaths);
        }
        ref.invalidate(receiptHistoryProvider);
      };
    } else if (currentTab == 1) {
      title = 'CLEAR PRODUCT HISTORY';
      onSwipe = () async {
        final repo = ref.read(productRepositoryProvider);
        final manager = ref.read(recordManagerServiceProvider);
        final records = await repo.getAll();
        for (final r in records) {
          await manager.deleteRecord(repository: repo, id: r.id, imagePaths: r.imagePaths);
        }
        ref.invalidate(productHistoryProvider);
      };
    } else if (currentTab == 2) {
      title = 'CLEAR COMPARISON HISTORY';
      onSwipe = () async {
        final repo = ref.read(comparisonRepositoryProvider);
        final manager = ref.read(recordManagerServiceProvider);
        final records = await repo.getAll();
        for (final r in records) {
          await manager.deleteRecord(repository: repo, id: r.id, imagePath: r.imagePath);
        }
        ref.invalidate(comparisonHistoryProvider);
      };
    }

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
                if (onSwipe != null) await onSwipe();
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
                    final manager = ref.read(recordManagerServiceProvider);
                    
                    if (data.type == HistoryType.receipt) {
                      await manager.deleteRecord(repository: ref.read(receiptRepositoryProvider), id: data.id, imagePath: data.imagePath);
                      ref.invalidate(receiptHistoryProvider);
                    } else if (data.type == HistoryType.product) {
                      await manager.deleteRecord(repository: ref.read(productRepositoryProvider), id: data.id, imagePaths: data.imagePaths);
                      ref.invalidate(productHistoryProvider);
                    } else if (data.type == HistoryType.comparison) {
                      await manager.deleteRecord(repository: ref.read(comparisonRepositoryProvider), id: data.id, imagePath: data.imagePath);
                      ref.invalidate(comparisonHistoryProvider);
                    }
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
