import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

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
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).copyWith(bottom: 100),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildReceiptCard(context, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildReceiptCard(BuildContext context, ReceiptRecord record, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Route to Receipt details
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
                        '\$ \${record.totalAmount.toStringAsFixed(2)}',
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
      ),
    );
  }
}
