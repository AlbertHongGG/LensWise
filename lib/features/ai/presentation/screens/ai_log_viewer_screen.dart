import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/ai/domain/models/ai_log_model.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/system_log_manager.dart';
import 'package:lens_wise/features/ai/presentation/screens/agent_log_detail_screen.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';

class AiLogViewerScreen extends ConsumerStatefulWidget {
  const AiLogViewerScreen({super.key});

  @override
  ConsumerState<AiLogViewerScreen> createState() => _AiLogViewerScreenState();
}

class _AiLogViewerScreenState extends ConsumerState<AiLogViewerScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _tabs = [];
  List<AiLogModel> _allLogs = [];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String _translateAgentName(String name) {
    switch (name) {
      case 'All': return '全部';
      case 'ProductComparison': return '商品比對';
      case 'ProductAnalysis': return '商品分析';
      case 'ReceiptParsing': return '發票掃描';
      default: return name;
    }
  }

  void _initializeTabs(List<FileSystemEntity> logFiles) {
    _allLogs = logFiles.map((f) => AiLogModel.fromFile(f)).toList();
    _allLogs.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final agentCategories = _allLogs.map((l) => l.agentName).toSet().toList();
    final newTabs = ['All', ...agentCategories];

    if (_tabs.length != newTabs.length || !_tabs.every((t) => newTabs.contains(t))) {
      _tabs = newTabs;
      _tabController?.dispose();
      _tabController = TabController(length: _tabs.length, vsync: this);
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
        MaterialPageRoute(builder: (context) => AgentLogDetailScreen(logData: json, fileName: fileName)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to read log: $e')));
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

  Widget _buildLogCard(AiLogModel log, String subtitle, bool isDark) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_outlined, 
            color: AppColors.primary
          ),
        ),
        title: Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => _openLogDetail(log.file, isDark),
      ),
    );
  }

  Widget _buildLogListView(List<AiLogModel> logs, bool isDark) {
    if (logs.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final subtitle = DateFormat('yyyy-MM-dd HH:mm:ss').format(log.dateTime);

        return LongPressDraggable<AiLogModel>(
          data: log,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.8,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: _buildLogCard(log, subtitle, isDark),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildLogCard(log, subtitle, isDark),
          ),
          child: _buildLogCard(log, subtitle, isDark),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final agentLogsAsync = ref.watch(agentLogListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: agentLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logFiles) {
          if (logFiles.isEmpty) {
            return SafeArea(
              child: Stack(
                children: [
                  _buildEmptyState(isDark),
                  _buildEdgeSwipeDetector(),
                ],
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
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
                        tabs: _tabs.map((tab) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Tab(text: _translateAgentName(tab)),
                        )).toList(),
                      ),
                    ),

                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _tabs.map((tab) {
                          final filteredLogs = tab == 'All' 
                            ? _allLogs 
                            : _allLogs.where((l) => l.agentName == tab).toList();
                          return KeyedSubtree(
                            key: ValueKey(tab),
                            child: _buildLogListView(filteredLogs, isDark),
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

              // Edge Swipe Detector for popping the screen
              _buildEdgeSwipeDetector(),
            ],
          );
        }
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
