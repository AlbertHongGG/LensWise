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
  rawJsonResult: json['rawJsonResult'] as String,
  imagePath: json['imagePath'] as String,
);

Map<String, dynamic> _$ProductComparisonRecordToJson(
  _ProductComparisonRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'rawJsonResult': instance.rawJsonResult,
  'imagePath': instance.imagePath,
};
