import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

part 'receipt_scanner_record.freezed.dart';
part 'receipt_scanner_record.g.dart';

@freezed
abstract class ReceiptScannerRecord with _$ReceiptScannerRecord implements IHistoryRecord {
  const ReceiptScannerRecord._();

  const factory ReceiptScannerRecord({
    required String id,
    required DateTime timestamp,
    String? receiptDate,
    required String storeName,
    String? currency,
    required double subtotal,
    @Default([]) List<ReceiptItem> items,
    @Default([]) List<ReceiptFeeItem> discounts,
    @Default([]) List<ReceiptFeeItem> taxes,
    required double totalAmount,
    @Default([]) List<String> imagePaths,
  }) = _ReceiptScannerRecord;

  factory ReceiptScannerRecord.fromJson(Map<String, dynamic> json) => _$ReceiptScannerRecordFromJson(json);

  factory ReceiptScannerRecord.empty() => ReceiptScannerRecord(
        id: '',
        timestamp: DateTime.now(),
        storeName: '',
        subtotal: 0.0,
        totalAmount: 0.0,
        items: const [],
        discounts: const [],
        taxes: const [],
        imagePaths: const [],
      );

  @override
  String get displayTitle => storeName.isNotEmpty ? storeName : '未知商家';

  @override
  String get displaySubtitle => totalAmount > 0 ? '\$${totalAmount.toStringAsFixed(2)}' : '無金額資訊';

  @override
  IconData get displayIcon => Icons.receipt_long_outlined;

  @override
  String? get deletionImagePath => null;

  @override
  List<String>? get deletionImagePaths => imagePaths;
}

@freezed
abstract class ReceiptItem with _$ReceiptItem {
  const factory ReceiptItem({
    required String originalName,
    required String translatedName,
    required double price,
  }) = _ReceiptItem;

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);
}

@freezed
abstract class ReceiptFeeItem with _$ReceiptFeeItem {
  const factory ReceiptFeeItem({
    required String name,
    required double amount,
  }) = _ReceiptFeeItem;

  factory ReceiptFeeItem.fromJson(Map<String, dynamic> json) => _$ReceiptFeeItemFromJson(json);
}