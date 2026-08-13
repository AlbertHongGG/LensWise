import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/record_manager_service.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/features/history/presentation/pages/unified_history_page.dart';

import 'package:lens_wise/features/history/presentation/widgets/animated_history_list.dart';

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
        return AnimatedHistoryList<ProductComparisonRecord>(
          records: records,
          areItemsTheSame: (a, b) => a.id == b.id,
          itemBuilder: (context, record) {
            return _buildComparisonCard(context, ref, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildComparisonCard(BuildContext context, WidgetRef ref, ProductComparisonRecord record, bool isDark) {
    final cardWidget = GlassContainer(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      opacity: isDark ? 0.05 : 0.8,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final result = record.result;
          final args = ProductComparisonResultArgs(
            result: result,
            imagePath: record.imagePath,
          );
          context.push('/result/comparison', extra: args);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.compare_arrows_outlined, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.result.title.isNotEmpty ? record.result.title : '規格比對紀錄',
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
                      record.result.comparisonPoints.isNotEmpty ? '${record.result.comparisonPoints.length} 項差異特徵' : '無差異特徵',
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
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LongPressDraggable<HistoryDragData>(
        data: HistoryDragData(record: record, controller: ref.read(comparisonHistoryProvider.notifier)),
        delay: const Duration(milliseconds: 200),
        feedback: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: Opacity(
              opacity: 0.8,
              child: Transform.scale(
                scale: 1.05,
                child: cardWidget,
              ),
            ),
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
