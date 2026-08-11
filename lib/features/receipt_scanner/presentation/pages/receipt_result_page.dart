import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'dart:io';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('收據解析結果', style: TextStyle(color: Colors.black)),
      ),
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
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          onPressed: () => context.pop(),
                          child: const Text('完成', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('編輯$title'),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: title.contains('金額') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              TextButton(
                onPressed: () {
                  onSave(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('儲存'),
              ),
            ],
          ),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編輯品項'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: originalNameCtrl, decoration: const InputDecoration(labelText: '原始品名')),
            TextField(controller: translatedNameCtrl, decoration: const InputDecoration(labelText: '翻譯品名')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: '金額'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final newItems = List<ReceiptItem>.from(record.items);
              newItems[index] = item.copyWith(
                originalName: originalNameCtrl.text,
                translatedName: translatedNameCtrl.text,
                price: double.tryParse(priceCtrl.text) ?? item.price,
              );
              _updateRecord(record.copyWith(items: newItems));
              Navigator.pop(context);
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void _updateRecord(ReceiptRecord updated) {
    ref.read(receiptScannerControllerProvider.notifier).updateReceiptRecord(updated);
  }
}
