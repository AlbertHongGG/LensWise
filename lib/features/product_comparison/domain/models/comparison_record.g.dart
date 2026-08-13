// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComparisonRecord _$ComparisonRecordFromJson(Map<String, dynamic> json) =>
    _ComparisonRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawJsonResult: json['rawJsonResult'] as String,
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$ComparisonRecordToJson(_ComparisonRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'rawJsonResult': instance.rawJsonResult,
      'imagePath': instance.imagePath,
    };
