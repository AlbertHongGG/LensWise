import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/domain/interfaces/i_receipt_scanner_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_scanner_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:uuid/uuid.dart';

class ReceiptScannerService {
  final Ref _ref;

  ReceiptScannerService(this._ref);

  /// 執行發票解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ReceiptScannerRecord?> analyzeAndSave(List<Uint8List> images) async {
    final agent = _ref.read(receiptScannerAgentProvider);
    final mediaService = _ref.read(localMediaServiceProvider);
    
    // 1. Call Port (Interface) to get Domain Entity (Parsed Data)
    final parsedRecord = await agent.execute(images);

    try {
      // 2. Orchestrate saving images
      final List<String> savedImagePaths = [];
      for (final imageBytes in images) {
        final path = await mediaService.saveImage(imageBytes);
        savedImagePaths.add(path);
      }
      
      // 3. Optional: Recalculate robust totals in application layer if needed
      final calculatedSubtotal = parsedRecord.items.fold<double>(0.0, (sum, item) => sum + item.price);
      final sumTaxes = parsedRecord.taxes.fold<double>(0.0, (sum, item) => sum + item.amount);
      final sumDiscounts = parsedRecord.discounts.fold<double>(0.0, (sum, item) => sum + item.amount);
      final calculatedTotal = calculatedSubtotal + sumTaxes + sumDiscounts;

      // 4. Hydrate the Domain Entity with Application Context (ID, Timestamp, Paths, Calculations)
      final record = parsedRecord.copyWith(
        id: const Uuid().v4(),
        timestamp: DateTime.now(),
        imagePaths: savedImagePaths,
        subtotal: calculatedSubtotal > 0 ? calculatedSubtotal : parsedRecord.subtotal,
        totalAmount: calculatedTotal > 0 ? calculatedTotal : parsedRecord.totalAmount,
      );

      // 5. Save via Controller (SSOT)
      await _ref.read(receiptHistoryProvider.notifier).saveRecord(record);
      
      return record;
    } catch (e) {
      throw Exception('資料儲存異常，請稍後再試');
    }
  }
}

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(ref);
});
