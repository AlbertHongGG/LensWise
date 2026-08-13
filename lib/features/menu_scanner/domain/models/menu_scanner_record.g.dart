// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_scanner_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MenuScannerRecord _$MenuScannerRecordFromJson(Map<String, dynamic> json) =>
    _MenuScannerRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      storeName: json['storeName'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => MenuScannerItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      translatedImagePaths:
          (json['translatedImagePaths'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$MenuScannerRecordToJson(_MenuScannerRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'storeName': instance.storeName,
      'items': instance.items,
      'imagePaths': instance.imagePaths,
      'translatedImagePaths': instance.translatedImagePaths,
    };

_MenuScannerItem _$MenuScannerItemFromJson(Map<String, dynamic> json) =>
    _MenuScannerItem(
      originalName: json['originalName'] as String,
      translatedName: json['translatedName'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$MenuScannerItemToJson(_MenuScannerItem instance) =>
    <String, dynamic>{
      'originalName': instance.originalName,
      'translatedName': instance.translatedName,
      'description': instance.description,
      'price': instance.price,
    };
