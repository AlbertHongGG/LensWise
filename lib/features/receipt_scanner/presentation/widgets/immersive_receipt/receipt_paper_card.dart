import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'receipt_item_row.dart';

class ReceiptPaperCard extends StatelessWidget {
  final ReceiptScannerRecord? initialRecord;
  final ReceiptScannerRecord? record;
  final Function(ReceiptScannerRecord) onUpdate;

  const ReceiptPaperCard({
    super.key,
    this.initialRecord,
    ReceiptScannerRecord? record,
    required this.onUpdate,
  }) : record = record ?? initialRecord;

  @override
  Widget build(BuildContext context) {
    final baseRecord = record ?? initialRecord ?? ReceiptScannerRecord.empty();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptPaperHeader(
            initialRecord: baseRecord,
            onUpdate: onUpdate,
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('品項', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              Text('金額', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          _ReceiptPaperItems(
            initialRecord: baseRecord,
            onUpdate: onUpdate,
          ),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          _ReceiptPaperTotals(
            initialRecord: baseRecord,
            onUpdate: onUpdate,
          ),
        ],
      ),
    );
  }
}

class _ReceiptPaperHeader extends ConsumerWidget {
  final ReceiptScannerRecord initialRecord;
  final Function(ReceiptScannerRecord) onUpdate;

  const _ReceiptPaperHeader({
    required this.initialRecord,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerData = ref.watch(receiptScannerControllerProvider.select((state) {
      final rec = state.receiptRecord ?? initialRecord;
      return (
        storeName: rec.storeName.isEmpty ? '未知商店' : rec.storeName,
        receiptDate: rec.receiptDate ?? rec.timestamp.toString().split('.')[0],
      );
    }));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableField(
          context: context,
          title: '商店名稱',
          value: headerData.storeName,
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          onSave: (val) {
            final current = ref.read(receiptScannerControllerProvider).receiptRecord ?? initialRecord;
            onUpdate(current.copyWith(storeName: val));
          },
        ),
        const SizedBox(height: 8),
        Text(headerData.receiptDate, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String title,
    required String value,
    required TextStyle textStyle,
    required Function(String) onSave,
  }) {
    return GestureDetector(
      onTap: () {
        final controller = TextEditingController(text: value);
        _showImmersiveBottomSheet(
          context: context,
          title: '編輯$title',
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onSave(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('儲存變更', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
      child: Text(value, style: textStyle),
    );
  }

  void _showImmersiveBottomSheet({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptPaperItems extends ConsumerWidget {
  final ReceiptScannerRecord initialRecord;
  final Function(ReceiptScannerRecord) onUpdate;

  const _ReceiptPaperItems({
    required this.initialRecord,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(receiptScannerControllerProvider.select((state) {
      final rec = state.receiptRecord ?? initialRecord;
      return rec.items;
    }));

    if (items.isEmpty) {
      return Column(
        children: const [
          StreamingSkeleton(width: double.infinity, height: 26, margin: EdgeInsets.symmetric(vertical: 4)),
          StreamingSkeleton(width: double.infinity, height: 26, margin: EdgeInsets.symmetric(vertical: 4)),
          StreamingSkeleton(width: double.infinity, height: 26, margin: EdgeInsets.symmetric(vertical: 4)),
        ],
      );
    }

    final activeRecord = ref.read(receiptScannerControllerProvider).receiptRecord ?? initialRecord;

    return Column(
      children: items.asMap().entries.map((e) {
        return ReceiptItemRow(
          item: e.value,
          index: e.key,
          record: activeRecord,
          onUpdate: onUpdate,
        );
      }).toList(),
    );
  }
}

class _ReceiptPaperTotals extends ConsumerWidget {
  final ReceiptScannerRecord initialRecord;
  final Function(ReceiptScannerRecord) onUpdate;

  const _ReceiptPaperTotals({
    required this.initialRecord,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(receiptScannerControllerProvider.select((state) {
      final rec = state.receiptRecord ?? initialRecord;
      return (
        subtotal: rec.subtotal,
        discounts: rec.discounts,
        taxes: rec.taxes,
        totalAmount: rec.totalAmount,
        currency: rec.currency ?? '',
      );
    }));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('小計', style: TextStyle(fontSize: 16, color: Colors.black87)),
            Text(totals.subtotal.toStringAsFixed(2), style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),

        // Discounts
        if (totals.discounts.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...totals.discounts.map((discount) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(discount.name, style: const TextStyle(fontSize: 14, color: Colors.red)),
              ),
              const SizedBox(width: 8),
              Text(discount.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 14, color: Colors.red)),
            ],
          )),
        ],

        // Taxes
        if (totals.taxes.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...totals.taxes.map((tax) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(tax.name, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ),
              const SizedBox(width: 8),
              Text(tax.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          )),
        ],

        const Divider(height: 32, thickness: 2, color: Colors.black),
        _buildEditableTotal(
          context: context,
          ref: ref,
          currency: totals.currency,
          totalAmount: totals.totalAmount,
        ),
      ],
    );
  }

  Widget _buildEditableTotal({
    required BuildContext context,
    required WidgetRef ref,
    required String currency,
    required double totalAmount,
  }) {
    return GestureDetector(
      onTap: () {
        final controller = TextEditingController(text: totalAmount.toStringAsFixed(2));
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('編輯總計', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        final numericStr = controller.text.replaceAll(RegExp(r'[^0-9.]'), '');
                        if (double.tryParse(numericStr) != null) {
                          final current = ref.read(receiptScannerControllerProvider).receiptRecord ?? initialRecord;
                          onUpdate(current.copyWith(totalAmount: double.parse(numericStr)));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('儲存變更', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Text(
        '$currency ${totalAmount.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
      ),
    );
  }
}
