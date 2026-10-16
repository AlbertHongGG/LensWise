import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

part 'menu_scanner_record.freezed.dart';
part 'menu_scanner_record.g.dart';

@freezed
abstract class MenuScannerRecord with _$MenuScannerRecord implements IHistoryRecord {
  const MenuScannerRecord._();

  const factory MenuScannerRecord({
    required String id,
    required DateTime timestamp,
    required String storeName,
    @Default([]) List<MenuScannerItem> items,
    @Default([]) List<String> imagePaths,
    @Default({}) Map<String, String> translatedImagePaths,
  }) = _MenuScannerRecord;

  factory MenuScannerRecord.fromJson(Map<String, dynamic> json) => _$MenuScannerRecordFromJson(json);

  factory MenuScannerRecord.empty() => MenuScannerRecord(
        id: '',
        timestamp: DateTime.now(),
        storeName: '',
        items: const [],
        imagePaths: const [],
        translatedImagePaths: const {},
      );

  @override
  String get displayTitle => storeName.isNotEmpty ? storeName : '未知餐廳菜單';

  @override
  String get displaySubtitle => '${items.length} 個品項';

  @override
  IconData get displayIcon => Icons.restaurant_menu;

  @override
  String? get deletionImagePath => null;

  @override
  List<String>? get deletionImagePaths => [
    ...imagePaths,
    ...translatedImagePaths.values,
  ];
}

@freezed
abstract class MenuScannerItem with _$MenuScannerItem {
  const factory MenuScannerItem({
    required String originalName,
    required String translatedName,
    String? description,
    required double price,
  }) = _MenuScannerItem;

  factory MenuScannerItem.fromJson(Map<String, dynamic> json) => _$MenuScannerItemFromJson(json);
}
