import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';

class ReceiptItemRow extends StatelessWidget {
  final ReceiptItem item;
  final int index;
  final ReceiptScannerRecord record;
  final Function(ReceiptScannerRecord) onUpdate;

  const ReceiptItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.record,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _editItemDialog(context),
        child: Container(
          color: Colors.transparent, // to make gesture detector work
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.translatedName.isNotEmpty)
                      Text(item.translatedName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text(item.originalName, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
              Text(item.price.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  void _editItemDialog(BuildContext context) {
    final originalNameCtrl = TextEditingController(text: item.originalName);
    final translatedNameCtrl = TextEditingController(text: item.translatedName);
    final priceCtrl = TextEditingController(text: item.price.toString());

    _showImmersiveBottomSheet(
      context: context,
      title: '編輯品項',
      children: [
        TextField(
          controller: originalNameCtrl, 
          decoration: InputDecoration(labelText: '原始品名', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: translatedNameCtrl, 
          decoration: InputDecoration(labelText: '翻譯品名', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: priceCtrl, 
          decoration: InputDecoration(labelText: '金額', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
      onConfirm: () {
        final newItems = List<ReceiptItem>.from(record.items);
        newItems[index] = item.copyWith(
          originalName: originalNameCtrl.text,
          translatedName: translatedNameCtrl.text,
          price: double.tryParse(priceCtrl.text) ?? item.price,
        );
        onUpdate(record.copyWith(items: newItems));
        Navigator.pop(context);
      },
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
