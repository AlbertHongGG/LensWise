import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/ai/domain/models/ai_log_model.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/system_log_manager.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/features/ai/presentation/screens/agent_log_detail_screen.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';

// --- AiLogListTab WITH KEEPALIVE ---
class AiLogListTab extends StatefulWidget {
  final List<AiLogModel> logs;
  final bool isDark;
  final void Function(FileSystemEntity, bool) onLogTap;

  const AiLogListTab({
    super.key,
    required this.logs,
    required this.isDark,
    required this.onLogTap,
  });

  @override
  State<AiLogListTab> createState() => _AiLogListTabState();
}

class _AiLogListTabState extends State<AiLogListTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // CRUCIAL: Keeps tab state alive off-screen

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '目前沒有系統日誌。',
        style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
      ),
    );
  }

  Widget _buildLogCard(AiLogModel log, String subtitle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
        ),
        title: Text(
          log.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => widget.onLogTap(log.file, widget.isDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // CRUCIAL: Required for AutomaticKeepAliveClientMixin

    if (widget.logs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 8),
      itemCount: widget.logs.length,
      itemBuilder: (context, index) {
        final log = widget.logs[index];
        final subtitle = DateFormat('yyyy-MM-dd HH:mm:ss').format(log.dateTime);

        return LongPressDraggable<AiLogModel>(
          data: log,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.8,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: _buildLogCard(log, subtitle),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildLogCard(log, subtitle),
          ),
          child: _buildLogCard(log, subtitle),
        );
      },
    );
  }
}

// --- MAIN SCREEN ---
class AiLogViewerScreen extends ConsumerStatefulWidget {
  const AiLogViewerScreen({super.key});

  @override
  ConsumerState<AiLogViewerScreen> createState() => _AiLogViewerScreenState();
}

class _AiLogViewerScreenState extends ConsumerState<AiLogViewerScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<AiAgentType?> _tabs = [];
  Map<AiAgentType?, List<AiLogModel>> _cachedFilteredLogs = {};

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabs(List<FileSystemEntity> logFiles) {
    final allLogs = logFiles
        .map((f) => AiLogModel.fromFile(f))
        .where((l) => l.type != null)
        .toList();
    allLogs.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final agentCategories = allLogs.map((l) => l.type!).toSet().toList();
    agentCategories.sort((a, b) => a.index.compareTo(b.index));
    final newTabs = <AiAgentType?>[null, ...agentCategories];

    // Data Pre-computation: Pre-filter logs to avoid Rebuild overhead
    final newCachedLogs = <AiAgentType?, List<AiLogModel>>{};
    for (final tab in newTabs) {
      if (tab == null) {
        newCachedLogs[tab] = allLogs;
      } else {
        newCachedLogs[tab] = allLogs.where((l) => l.type == tab).toList();
      }
    }
    _cachedFilteredLogs = newCachedLogs;

    if (_tabs.length != newTabs.length ||
        !_tabs.every((t) => newTabs.contains(t))) {
      _tabs = newTabs;
      final oldIndex = _tabController?.index ?? 0;
      _tabController?.dispose();
      _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: oldIndex >= _tabs.length ? 0 : oldIndex,
      );
    }
  }

  void _clearAllLogs() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: 48,
        ),
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
                'CLEAR AI LOGS',
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
              title: 'SLIDE TO WIPE',
              isLoading: false,
              activeColor: Colors.redAccent,
              onConfirmed: () async {
                Navigator.pop(ctx);
                await ref.read(systemLogManagerProvider).clearAllLogs();
                ref.invalidate(agentLogListProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openLogDetail(FileSystemEntity file, bool isDark) async {
    try {
      final content = await File(file.path).readAsString();
      final json = jsonDecode(content);

      if (!mounted) return;

      final fileName = file.path.split(Platform.pathSeparator).last;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AgentLogDetailScreen(logData: json, fileName: fileName),
        ),
      );
    } catch (e) {
      ref.read(notificationProvider.notifier).showError('Failed to read log: $e');
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return const Center(
      child: Text(
        '目前沒有系統日誌。',
        style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final agentLogsAsync = ref.watch(agentLogListProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: agentLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logFiles) {
          if (logFiles.isEmpty) {
            return SafeArea(
              child: Stack(
                children: [_buildEmptyState(isDark), _buildEdgeSwipeDetector()],
              ),
            );
          }

          _initializeTabs(logFiles);

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // TabBar Only
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        indicator: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: isDark ? Colors.white : AppColors.primary,
                        unselectedLabelColor: isDark
                            ? Colors.white54
                            : Colors.black54,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        splashBorderRadius: BorderRadius.circular(12),
                        tabs: _tabs
                            .map(
                              (tab) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Tab(text: tab == null ? '全部' : tab.displayName),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    // RESTORED: Native TabBarView with KeepAlive Tabs
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        // Not using NeverScrollableScrollPhysics so users CAN slide it
                        children: _tabs.map((tab) {
                          final filteredLogs = _cachedFilteredLogs[tab] ?? [];
                          return AiLogListTab(
                            key: ValueKey(tab?.id ?? 'all'), // Crucial for state matching
                            logs: filteredLogs,
                            isDark: isDark,
                            onLogTap: _openLogDetail,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Trash Can Target
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: DragTarget<AiLogModel>(
                    onAcceptWithDetails: (details) async {
                      final log = details.data;
                      if (await log.file.exists()) {
                        await log.file.delete();
                      }
                      ref.invalidate(agentLogListProvider);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;

                      return GestureDetector(
                        onTap: _clearAllLogs,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isHovering ? 64 : 56,
                          height: isHovering ? 64 : 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isHovering
                                ? Colors.redAccent.withValues(alpha: 0.9)
                                : (isDark
                                      ? Colors.black.withValues(alpha: 0.6)
                                      : Colors.white.withValues(alpha: 0.8)),
                            boxShadow: [
                              BoxShadow(
                                color: isHovering
                                    ? Colors.redAccent.withValues(alpha: 0.4)
                                    : Colors.black.withValues(alpha: 0.1),
                                blurRadius: isHovering ? 20 : 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isHovering
                                  ? Colors.red
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: isHovering ? 2 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Icon(
                                isHovering
                                    ? Icons.delete_forever
                                    : Icons.delete_outline,
                                color: isHovering
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
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

              // Edge Swipe Detector for popping the screen
              _buildEdgeSwipeDetector(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEdgeSwipeDetector() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 40,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}
