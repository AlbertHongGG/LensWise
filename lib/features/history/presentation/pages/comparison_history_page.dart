import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';

class ComparisonHistoryPage extends ConsumerWidget {
  const ComparisonHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(comparisonHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('比對決策紀錄', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('目前沒有紀錄，點擊下方「➕」開始掃描。', style: TextStyle(color: Colors.white54)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  opacity: 0.1,
                  child: ListTile(
                    title: Text('${record.products.length} 項商品比對', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(record.timestamp.toString().substring(0, 16), style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
