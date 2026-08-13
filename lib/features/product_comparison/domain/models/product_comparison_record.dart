import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

part 'product_comparison_record.freezed.dart';
part 'product_comparison_record.g.dart';

@freezed
abstract class ProductComparisonRecord with _$ProductComparisonRecord implements IHistoryRecord {
  const ProductComparisonRecord._();

  const factory ProductComparisonRecord({
    required String id,
    required DateTime timestamp,
    required String rawJsonResult,
    required String imagePath,
  }) = _ProductComparisonRecord;

  factory ProductComparisonRecord.fromJson(Map<String, dynamic> json) => _$ProductComparisonRecordFromJson(json);

  @override
  String get displayTitle => '商品比對紀錄';

  @override
  String get displaySubtitle => '點擊查看比對結果';

  @override
  IconData get displayIcon => Icons.compare_arrows_outlined;

  @override
  String? get deletionImagePath => imagePath;

  @override
  List<String>? get deletionImagePaths => imagePath.split(',');
}
