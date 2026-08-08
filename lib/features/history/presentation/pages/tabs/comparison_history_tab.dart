import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

class ComparisonHistoryTab extends ConsumerWidget {
  const ComparisonHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(comparisonHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return const PremiumEmptyState(
            icon: Icons.compare_arrows_outlined,
            title: '尚無規格比對紀錄',
            description: '所有雙物件的規格比對與推薦，\n都會儲存為獨立的情報檔案。',
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).copyWith(bottom: 100),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildComparisonCard(context, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildComparisonCard(BuildContext context, ComparisonRecord record, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Route to Comparison details
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.balance_outlined, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\${record.productA} vs \${record.productB}',
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
                        '推薦: \${record.recommendation}',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
