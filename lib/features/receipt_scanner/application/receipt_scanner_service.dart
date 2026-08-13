import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/interfaces/i_receipt_parsing_agent.dart';
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
    final result = await _agent.execute(images);

    if (result.status == 'success' && result.data != null) {
      try {
        final List<String> savedImagePaths = [];
        for (final imageBytes in images) {
          final path = await _mediaService.saveImage(imageBytes);
          savedImagePaths.add(path);
        }
        final data = result.data!;
        
        final List<ReceiptItem> processedItems = [];
        if (data['items'] is List) {
          for (final item in data['items'] as List) {
            if (item is Map) {
              processedItems.add(ReceiptItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }

        final List<ReceiptFeeItem> processedDiscounts = [];
        if (data['discounts'] is List) {
          for (final item in data['discounts'] as List) {
            if (item is Map) {
              processedDiscounts.add(ReceiptFeeItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }

        final List<ReceiptFeeItem> processedTaxes = [];
        if (data['taxes'] is List) {
          for (final item in data['taxes'] as List) {
            if (item is Map) {
              processedTaxes.add(ReceiptFeeItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }

        final calculatedSubtotal = processedItems.fold<double>(0.0, (sum, item) => sum + item.price);
        final sumTaxes = processedTaxes.fold<double>(0.0, (sum, item) => sum + item.amount);
        final sumDiscounts = processedDiscounts.fold<double>(0.0, (sum, item) => sum + item.amount);
        final calculatedTotal = calculatedSubtotal + sumTaxes + sumDiscounts;

        String? parsedReceiptDate = data['receiptDateTime']?.toString();
        if (parsedReceiptDate != null && parsedReceiptDate.isEmpty) {
          parsedReceiptDate = null;
        }

        String? parsedCurrency = data['currency']?.toString();
        if (parsedCurrency != null && parsedCurrency.isEmpty) {
          parsedCurrency = null;
        }

        final record = ReceiptRecord(
          id: const Uuid().v4(),
          timestamp: DateTime.now(),
          receiptDate: parsedReceiptDate,
          storeName: data['storeName']?.toString() ?? '',
          currency: parsedCurrency,
          subtotal: calculatedSubtotal,
          items: processedItems,
          discounts: processedDiscounts,
          taxes: processedTaxes,
          totalAmount: calculatedTotal,
          imagePaths: savedImagePaths,
        );
        await _repository.save(record.id, record);
        return record;
      } catch (e) {
        print('Error saving receipt to history: $e');
      }
    }

    if (result.status != 'success') {
      throw Exception(result.message ?? '解析失敗');
    }
    
    return null;
  }
}

final receiptScannerServiceProvider = Provider<ReceiptScannerService>((ref) {
  return ReceiptScannerService(
    ref.watch(receiptParsingAgentProvider),
    ref.watch(receiptRepositoryProvider),
    ref.watch(localMediaServiceProvider),
  );
});
