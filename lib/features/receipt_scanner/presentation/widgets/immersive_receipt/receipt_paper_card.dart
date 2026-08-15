import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'receipt_item_row.dart';

class ReceiptPaperCard extends StatelessWidget {
  final ReceiptScannerRecord record;
  final Function(ReceiptScannerRecord) onUpdate;

  const ReceiptPaperCard({
    super.key,
    required this.record,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditableField(
            context: context,
            title: '商店名稱',
            value: record.storeName ?? '未知商店',
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            onSave: (val) => onUpdate(record.copyWith(storeName: val)),
          ),
          const SizedBox(height: 8),
          Text(record.receiptDate ?? record.timestamp.toString().split('.')[0], style: const TextStyle(color: Colors.grey)),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('品項', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              Text('金額', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          ...record.items.asMap().entries.map((e) {
            return ReceiptItemRow(
              item: e.value,
              index: e.key,
              record: record,
              onUpdate: onUpdate,
            );
          }),
          const Divider(height: 32, thickness: 1, color: Colors.black12),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('小計', style: TextStyle(fontSize: 16, color: Colors.black87)),
              Text(record.subtotal.toStringAsFixed(2), style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
          
          // Discounts
          if (record.discounts.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...record.discounts.map((discount) => Row(
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
          if (record.taxes.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...record.taxes.map((tax) => Row(
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
          _buildEditableField(
            context: context,
            title: '總計',
            value: '${record.currency ?? ''} ${record.totalAmount.toStringAsFixed(2)}',
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
            onSave: (val) {
              final numericStr = val.replaceAll(RegExp(r'[^0-9.]'), '');
              if (double.tryParse(numericStr) != null) {
                onUpdate(record.copyWith(totalAmount: double.parse(numericStr)));
              }
            },
          ),
        ],
      ),
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
              keyboardType: title.contains('金額') || title.contains('總計') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: title,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
              ),
            ),
          ],
          onConfirm: () {
            onSave(controller.text);
            Navigator.pop(context);
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(value, style: textStyle)),
          const Icon(Icons.edit, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _showImmersiveBottomSheet({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final secondaryTextColor = isDark ? Colors.white54 : Colors.black54;

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05))),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        // Header with Title and Done Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 48), // Spacer for centering
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: secondaryTextColor,
                              ),
                            ),
                            IconButton(
                              onPressed: onConfirm,
                              icon: const Icon(Icons.check_circle_rounded),
                              color: theme.primaryColor,
                              iconSize: 28,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Content
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
