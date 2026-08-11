import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'dart:io';
import 'dart:ui';

class ReceiptResultPage extends ConsumerStatefulWidget {
  const ReceiptResultPage({super.key});

  @override
  ConsumerState<ReceiptResultPage> createState() => _ReceiptResultPageState();
}

class _ReceiptResultPageState extends ConsumerState<ReceiptResultPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScannerControllerProvider);
    final record = state.receiptRecord;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background to make receipt pop
      body: state.isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text('AI 正在仔細閱讀收據...', style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          : record == null
              ? Center(child: Text(state.errorMessage ?? '無解析結果', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 40.0), // Standard padding without close button
                  child: Column(
                    children: [
                      if (record.imagePath != null && record.imagePath!.isNotEmpty)
                        Container(
                          height: 150,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(record.imagePath!)),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                            ],
                          ),
                        ),
                      _buildPaperReceipt(record),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaperReceipt(ReceiptRecord record) {
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
            title: '商店名稱',
            value: record.storeName ?? '未知商店',
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            onSave: (val) => _updateRecord(record.copyWith(storeName: val)),
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
            final idx = e.key;
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () => _editItemDialog(record, idx),
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
              children: [
                Text(discount.name, style: const TextStyle(fontSize: 14, color: Colors.red)),
                Text(discount.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 14, color: Colors.red)),
              ],
            )),
          ],

          // Taxes
          if (record.taxes.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...record.taxes.map((tax) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tax.name, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                Text(tax.amount.toStringAsFixed(2), style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            )),
          ],

          const Divider(height: 32, thickness: 2, color: Colors.black),
          _buildEditableField(
            title: '總計',
            value: '${record.currency ?? ''} ${record.totalAmount.toStringAsFixed(2)}',
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
            onSave: (val) {
              // Extract numeric part gracefully
              final numericStr = val.replaceAll(RegExp(r'[^0-9.]'), '');
              if (double.tryParse(numericStr) != null) {
                _updateRecord(record.copyWith(totalAmount: double.parse(numericStr)));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
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

  void _editItemDialog(ReceiptRecord record, int index) {
    final item = record.items[index];
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
        _updateRecord(record.copyWith(items: newItems));
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

  void _updateRecord(ReceiptRecord updated) {
    ref.read(receiptScannerControllerProvider.notifier).updateReceiptRecord(updated);
  }
}
