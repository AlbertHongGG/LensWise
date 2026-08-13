import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

part 'receipt_record.freezed.dart';
part 'receipt_record.g.dart';

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

@freezed
abstract class ReceiptRecord with _$ReceiptRecord implements IHistoryRecord {
  const ReceiptRecord._();

  const factory ReceiptRecord({
    required String id,
    required DateTime timestamp,
    String? receiptDate,
    String? storeName,
    String? currency,
    required double subtotal,
    required List<ReceiptItem> items,
    @Default([]) List<ReceiptFeeItem> discounts,
    @Default([]) List<ReceiptFeeItem> taxes,
    required double totalAmount,
    @Default([]) List<String> imagePaths,
  }) = _ReceiptRecord;

  factory ReceiptRecord.fromJson(Map<String, dynamic> json) => _$ReceiptRecordFromJson(json);

  @override
  String get displayTitle => storeName?.isNotEmpty == true ? storeName! : '未知商店';

  @override
  String get displaySubtitle => '總計: $totalAmount ${currency ?? ""}';

  @override
  IconData get displayIcon => Icons.receipt_long;

  @override
  String? get deletionImagePath => null;

  @override
  List<String>? get deletionImagePaths => imagePaths;
}
