import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/history/domain/models/history_tab_config.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/history/presentation/widgets/animated_history_list.dart';

class GenericHistoryTabView<T extends IHistoryRecord> extends ConsumerWidget {
  final HistoryTabConfig<T> config;

  const GenericHistoryTabView({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = config.watchHistory(ref);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return PremiumEmptyState(
            icon: config.emptyStateIcon,
            title: config.emptyStateTitle,
            description: config.emptyStateDescription,
          );
        }
        return AnimatedHistoryList<T>(
          records: records,
          areItemsTheSame: (a, b) => a.id == b.id,
          itemBuilder: (context, record) {
            return config.cardBuilder(context, ref, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          '載入失敗: $err',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
