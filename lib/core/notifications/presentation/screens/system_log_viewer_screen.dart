import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/core/widgets/premium_config_header.dart';
import 'package:lens_wise/core/widgets/swipe_to_obliterate_button.dart';
import 'package:lens_wise/core/notifications/presentation/providers/system_log_provider.dart';

class SystemLogViewerScreen extends ConsumerStatefulWidget {
  const SystemLogViewerScreen({super.key});

  @override
  ConsumerState<SystemLogViewerScreen> createState() => _SystemLogViewerScreenState();
}

class _SystemLogViewerScreenState extends ConsumerState<SystemLogViewerScreen> {
  void _showClearAllDrawer() {
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
                'CLEAR SYSTEM LOGS',
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
                await ref.read(systemLogManagerProvider).clearAllLogs();
                ref.invalidate(systemLogListProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logFilesAsync = ref.watch(systemLogListProvider);

    return ImmersiveScaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: PremiumConfigHeader(
                      title: '系統通知日誌',
                      subtitle: 'SYSTEM NOTIFICATION LOG',
                    ),
                  ),
                ),
              ),
              logFilesAsync.when(
                data: (files) {
                  if (files.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          '目前沒有系統通知日誌。',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Reverse to show newest first
                  final reversedFiles = files.reversed.toList();

                  return SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final file = reversedFiles[index];
                          return FutureBuilder<String>(
                            future: File(file.path).readAsString(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              
                              try {
                                final data = jsonDecode(snapshot.data!) as Map<String, dynamic>;
                                final type = data['type'] as String? ?? 'info';
                                final message = data['message'] as String? ?? '';
                                final timestampStr = data['timestamp'] as String? ?? '';
                                
                                DateTime? timestamp;
                                if (timestampStr.isNotEmpty) {
                                  timestamp = DateTime.tryParse(timestampStr);
                                }
                                
                                final color = _getColorForType(type);
                                
                                return LongPressDraggable<FileSystemEntity>(
                                  data: file,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Opacity(
                                      opacity: 0.8,
                                      child: _buildCard(isDark, type, message, timestampStr, color, true),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildCard(isDark, type, message, timestampStr, color, false),
                                  ),
                                  child: _buildCard(isDark, type, message, timestampStr, color, false),
                                );
                              } catch (e) {
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        },
                        childCount: reversedFiles.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
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
              child: DragTarget<FileSystemEntity>(
                onAcceptWithDetails: (details) async {
                  await ref.read(systemLogManagerProvider).clearLog(details.data);
                  ref.invalidate(systemLogListProvider);
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
                            color: isHovering 
                                ? Colors.white 
                                : (isDark ? Colors.white70 : Colors.black54),
                            size: isHovering ? 28 : 24,
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
    );
  }

  Widget _buildCard(bool isDark, String type, String message, String timestampStr, Color color, bool isDragging) {
    return Card(
      elevation: isDragging ? 12 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_getIconForType(type), color: color, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timestampStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
