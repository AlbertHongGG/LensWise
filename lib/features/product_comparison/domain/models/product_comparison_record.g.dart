// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_comparison_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductComparisonRecord _$ProductComparisonRecordFromJson(
  Map<String, dynamic> json,
) => _ProductComparisonRecord(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  title: json['title'] as String,
  summary: json['summary'] as String,
  products:
      (json['products'] as List<dynamic>?)
          ?.map((e) => ComparisonProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  comparisonPoints:
      (json['comparisonPoints'] as List<dynamic>?)
          ?.map((e) => ComparisonPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  imagePaths:
      (json['imagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$ProductComparisonRecordToJson(
  _ProductComparisonRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'title': instance.title,
  'summary': instance.summary,
  'products': instance.products,
  'comparisonPoints': instance.comparisonPoints,
  'imagePaths': instance.imagePaths,
};

_ComparisonProduct _$ComparisonProductFromJson(Map<String, dynamic> json) =>
    _ComparisonProduct(
      originalName: json['originalName'] as String,
      translatedName: json['translatedName'] as String,
    );

Map<String, dynamic> _$ComparisonProductToJson(_ComparisonProduct instance) =>
    <String, dynamic>{
      'originalName': instance.originalName,
      'translatedName': instance.translatedName,
    };

_ComparisonPoint _$ComparisonPointFromJson(Map<String, dynamic> json) =>
    _ComparisonPoint(
      aspect: json['aspect'] as String,
      values:
          (json['values'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ComparisonPointToJson(_ComparisonPoint instance) =>
    <String, dynamic>{'aspect': instance.aspect, 'values': instance.values};
