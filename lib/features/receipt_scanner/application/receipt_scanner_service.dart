import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_scanner_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:uuid/uuid.dart';

class ReceiptScannerService {
  final Ref _ref;

  ReceiptScannerService(this._ref);

  Future<ReceiptScannerRecord?> analyzeAndSave(List<Uint8List> images) async {
    final agent = _ref.read(receiptScannerAgentProvider);
    final parsedRecord = await agent.execute(images);
    return saveCompletedRecord(parsedRecord, images);
  }

  /// 串流完成時持久化發票記錄與圖片
  Future<ReceiptScannerRecord> saveCompletedRecord(ReceiptScannerRecord parsedRecord, List<Uint8List> images) async {
    final mediaService = _ref.read(localMediaServiceProvider);
    final List<String> savedImagePaths = [];
    for (final imageBytes in images) {
      final path = await mediaService.saveImage(imageBytes);
      savedImagePaths.add(path);
    }
    
    final calculatedSubtotal = parsedRecord.items.fold<double>(0.0, (sum, item) => sum + item.price);
    final sumTaxes = parsedRecord.taxes.fold<double>(0.0, (sum, item) => sum + item.amount);
    final sumDiscounts = parsedRecord.discounts.fold<double>(0.0, (sum, item) => sum + item.amount);
    final calculatedTotal = calculatedSubtotal + sumTaxes + sumDiscounts;

    final record = parsedRecord.copyWith(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      imagePaths: savedImagePaths,
      subtotal: calculatedSubtotal > 0 ? calculatedSubtotal : parsedRecord.subtotal,
      totalAmount: calculatedTotal > 0 ? calculatedTotal : parsedRecord.totalAmount,
    );

    await _ref.read(receiptHistoryProvider.notifier).saveRecord(record);
    return record;
  }
}

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(ref);
});
