import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/history/domain/models/history_tab_config.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/history/presentation/widgets/draggable_history_card.dart';

import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

final defaultHistoryConfigs = <HistoryTabConfig>[
  HistoryTabConfig<ReceiptScannerRecord>(
    tabName: '收據',
    tabIcon: Icons.receipt_long,
    emptyStateTitle: '尚無發票帳目紀錄',
    emptyStateDescription: '所有透過相機掃描的發票資訊，\n都會有條理地整理在此。',
    emptyStateIcon: Icons.receipt_long_outlined,
    watchHistory: (ref) => ref.watch(receiptHistoryProvider),
    readController: (ref) => ref.read(receiptHistoryProvider.notifier),
    cardBuilder: (context, ref, IHistoryRecord rawRecord, isDark) {
      final record = rawRecord as ReceiptScannerRecord;
      final card = GlassContainer(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/result/receipt', extra: {
              'record': record,
              'memoryImages': null,
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
                  child: Icon(Icons.storefront_outlined, color: Theme.of(context).primaryColor),
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

      return DraggableHistoryCard<ReceiptScannerRecord>(
        record: record,
        controller: ref.read(receiptHistoryProvider.notifier),
        child: card,
      );
    },
  ),
  HistoryTabConfig<ProductLensRecord>(
    tabName: '商品',
    tabIcon: Icons.qr_code_scanner,
    emptyStateTitle: '尚無商品解析紀錄',
    emptyStateDescription: '所有透過相機掃描的商品特徵與解析，\n都會有條理地整理在此。',
    emptyStateIcon: Icons.qr_code_scanner_outlined,
    watchHistory: (ref) => ref.watch(productHistoryProvider),
    readController: (ref) => ref.read(productHistoryProvider.notifier),
    cardBuilder: (context, ref, IHistoryRecord rawRecord, isDark) {
      final record = rawRecord as ProductLensRecord;
      final card = GlassContainer(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/product/detail', extra: {'record': record});
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
      );

      return DraggableHistoryCard<ProductLensRecord>(
        record: record,
        controller: ref.read(productHistoryProvider.notifier),
        child: card,
      );
    },
  ),
  HistoryTabConfig<ProductComparisonRecord>(
    tabName: '比對',
    tabIcon: Icons.compare_arrows,
    emptyStateTitle: '尚無規格比對紀錄',
    emptyStateDescription: '所有雙物件的規格比對與推薦，\n都會儲存為獨立的情報檔案。',
    emptyStateIcon: Icons.compare_arrows_outlined,
    watchHistory: (ref) => ref.watch(comparisonHistoryProvider),
    readController: (ref) => ref.read(comparisonHistoryProvider.notifier),
    cardBuilder: (context, ref, IHistoryRecord rawRecord, isDark) {
      final record = rawRecord as ProductComparisonRecord;
      final card = GlassContainer(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/result/comparison', extra: {
              'record': record,
              'memoryImages': null,
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
                  child: Icon(Icons.compare_arrows_outlined, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title.isNotEmpty ? record.title : '規格比對紀錄',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

      return DraggableHistoryCard<ProductComparisonRecord>(
        record: record,
        controller: ref.read(comparisonHistoryProvider.notifier),
        child: card,
      );
    },
  ),
  HistoryTabConfig<MenuScannerRecord>(
    tabName: '菜單',
    tabIcon: Icons.restaurant_menu,
    emptyStateTitle: '尚無菜單辨識紀錄',
    emptyStateDescription: '所有辨識與翻譯過的外語菜單，\n都會儲存在這裡。',
    emptyStateIcon: Icons.restaurant_menu_outlined,
    watchHistory: (ref) => ref.watch(menuHistoryProvider),
    readController: (ref) => ref.read(menuHistoryProvider.notifier),
    cardBuilder: (context, ref, IHistoryRecord rawRecord, isDark) {
      final record = rawRecord as MenuScannerRecord;
      final card = GlassContainer(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        opacity: isDark ? 0.05 : 0.8,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push('/result/menu', extra: {
              'record': record,
              'memoryImages': null,
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
                  child: Icon(Icons.restaurant_menu_outlined, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.displayTitle,
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
                        record.displaySubtitle,
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
      );

      return DraggableHistoryCard<MenuScannerRecord>(
        record: record,
        controller: ref.read(menuHistoryProvider.notifier),
        child: card,
      );
    },
  ),
];
