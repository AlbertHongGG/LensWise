import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/domain/interfaces/i_receipt_parsing_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_parsing_agent/receipt_parsing_agent.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_repository.dart';
import 'package:uuid/uuid.dart';

class ReceiptScannerService {
  final IReceiptParsingAgent _agent;
  final IReceiptRepository _repository;
  final LocalMediaService _mediaService;

  ReceiptScannerService(this._agent, this._repository, this._mediaService);

  /// 執行發票解析並自動將成功的結果存入歷史紀錄 (Application Layer Orchestration)
  Future<ReceiptRecord?> analyzeAndSave(List<Uint8List> images) async {
    // 1. Call Port (Interface) to get Domain Entity (Parsed Data)
    final parsedRecord = await _agent.execute(images);

    try {
      // 2. Orchestrate saving images
      final List<String> savedImagePaths = [];
      for (final imageBytes in images) {
        final path = await _mediaService.saveImage(imageBytes);
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

      // 5. Save via Repository Port
      await _repository.save(record.id, record);
      
      return record;
    } catch (e) {
      throw Exception('資料儲存異常，請稍後再試');
    }
  }
}

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(
    ref.watch(receiptParsingAgentProvider),
    ref.watch(receiptRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
