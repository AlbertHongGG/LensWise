import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'dart:convert';

part 'comparison_record.freezed.dart';
part 'comparison_record.g.dart';

@freezed
abstract class ComparisonRecord with _$ComparisonRecord implements IHistoryRecord {
  const ComparisonRecord._();

  const factory ComparisonRecord({
    required String id,
    required DateTime timestamp,
    required String rawJsonResult,
    String? imagePath,
  }) = _ComparisonRecord;

  factory ComparisonRecord.fromJson(Map<String, dynamic> json) => _$ComparisonRecordFromJson(json);

  @override
  String get displayTitle => '商品比對紀錄';

  @override
  String get displaySubtitle => '產生於 ${timestamp.month}/${timestamp.day}';

  @override
  IconData get displayIcon => Icons.compare_arrows;

  @override
  String? get deletionImagePath => imagePath;

  @override
  List<String>? get deletionImagePaths => null;

  ComparisonResult get result {
    final map = jsonDecode(rawJsonResult) as Map<String, dynamic>;
    return ComparisonResult.fromJson(map);
  }
}
