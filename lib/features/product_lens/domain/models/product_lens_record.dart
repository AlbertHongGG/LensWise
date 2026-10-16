import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

part 'product_lens_record.freezed.dart';
part 'product_lens_record.g.dart';

@freezed
abstract class ProductLensRecord with _$ProductLensRecord implements IHistoryRecord {
  const ProductLensRecord._();

  const factory ProductLensRecord({
    required String id,
    required DateTime timestamp,
    required String productName,
    required String originalName,
    required String brand,
    required String origin,
    required String summary,
    required List<String> ingredients,
    required List<String> allergenAlerts,
    required List<String> dietaryFlags,
    required List<String> whenRecommended,
    required List<String> whenNotRecommended,
    @Default([]) List<String> imagePaths,
  }) = _ProductLensRecord;

  factory ProductLensRecord.fromJson(Map<String, dynamic> json) => _$ProductLensRecordFromJson(json);

  factory ProductLensRecord.empty() => ProductLensRecord(
        id: '',
        timestamp: DateTime.now(),
        productName: '',
        originalName: '',
        brand: '',
        origin: '',
        summary: '',
        ingredients: const [],
        allergenAlerts: const [],
        dietaryFlags: const [],
        whenRecommended: const [],
        whenNotRecommended: const [],
        imagePaths: const [],
      );

  @override
  String get displayTitle => productName.isNotEmpty ? productName : (originalName.isNotEmpty ? originalName : '未知商品');

  @override
  String get displaySubtitle => brand.isEmpty ? '未知品牌' : brand;

  @override
  IconData get displayIcon => Icons.inventory_2_outlined;

  @override
  String? get deletionImagePath => null;

  @override
  List<String>? get deletionImagePaths => imagePaths;
}
