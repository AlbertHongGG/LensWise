import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';

import 'package:lens_wise/features/history/domain/models/history_tab_config.dart';
import 'package:lens_wise/features/history/presentation/widgets/generic_history_tab_view.dart';
import 'dart:ui';

class UnifiedHistoryPage extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final List<HistoryTabConfig> configs;

  const UnifiedHistoryPage({
    super.key, 
    this.initialTabIndex = 0,
    required this.configs,
  });

  @override
  ConsumerState<UnifiedHistoryPage> createState() => _UnifiedHistoryPageState();
}

class _UnifiedHistoryPageState extends ConsumerState<UnifiedHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.configs.length,
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

  void _showClearAllDrawer() {
    if (widget.configs.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = widget.configs[_tabController.index];
    final controller = config.readController(ref);
    final title = 'CLEAR ${config.tabName.toUpperCase()} HISTORY';

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
    if (widget.configs.isEmpty) {
      return const Scaffold(body: Center(child: Text('No history configured.')));
    }

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
                    tabs: widget.configs.map((config) => Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(config.tabIcon, size: 16),
                          const SizedBox(width: 6),
                          Text(config.tabName),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: widget.configs.map((config) => GenericHistoryTabView(config: config)).toList(),
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
