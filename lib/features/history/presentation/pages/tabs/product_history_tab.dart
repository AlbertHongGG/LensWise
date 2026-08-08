import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/history/presentation/widgets/premium_empty_state.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

class ProductHistoryTab extends ConsumerWidget {
  const ProductHistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(productHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return const PremiumEmptyState(
            icon: Icons.qr_code_scanner_outlined,
            title: '尚無商品解析紀錄',
            description: '所有透過相機解析的商品情報，\n都會安全地保存在這裡。',
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).copyWith(bottom: 100),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildProductCard(context, record, isDark);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('載入失敗: $err', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductRecord record, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/product/detail', extra: {
              'record': record,
            });
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
                  child: Icon(Icons.inventory_2_outlined, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.productName,
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
                        record.brand.isEmpty ? '未知品牌' : record.brand,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 13,
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
