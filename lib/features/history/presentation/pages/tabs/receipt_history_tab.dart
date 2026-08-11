import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/history/presentation/pages/unified_history_page.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

import 'package:lens_wise/features/history/presentation/widgets/animated_history_list.dart';

class ReceiptHistoryTab extends ConsumerWidget {
  const ReceiptHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(receiptHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return const PremiumEmptyState(
            icon: Icons.receipt_long_outlined,
            title: '尚無發票帳目紀錄',
            description: '所有透過相機掃描的發票資訊，\n都會有條理地整理在此。',
          );
        }
        return AnimatedHistoryList<ReceiptRecord>(
          records: records,
          areItemsTheSame: (a, b) => a.id == b.id,
          itemBuilder: (context, record) {
            return _buildReceiptCard(context, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildReceiptCard(BuildContext context, ReceiptRecord record, bool isDark) {
    final cardWidget = GlassContainer(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      opacity: isDark ? 0.05 : 0.8,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/result/receipt', extra: record);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_outlined, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.imagePaths.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(record.imagePaths.first),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                    Text(
                      record.storeName ?? '未知商店',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.currency ?? ''} ${record.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.black26),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LongPressDraggable<HistoryDragData>(
        data: HistoryDragData(id: record.id, imagePaths: record.imagePaths, type: HistoryType.receipt),
        delay: const Duration(milliseconds: 200),
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width - 32,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.redAccent.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)
              ]
            ),
            child: Opacity(opacity: 0.8, child: _buildReceiptCard(context, record, isDark)),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.2,
          child: cardWidget,
        ),
        child: cardWidget,
      ),
    );
  }
}
