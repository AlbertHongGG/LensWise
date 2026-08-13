// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductRecord _$ProductRecordFromJson(Map<String, dynamic> json) =>
    _ProductRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      productName: json['productName'] as String,
      originalName: json['originalName'] as String,
      brand: json['brand'] as String,
      origin: json['origin'] as String,
      summary: json['summary'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergenAlerts: (json['allergenAlerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dietaryFlags: (json['dietaryFlags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      whenRecommended: (json['whenRecommended'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      whenNotRecommended: (json['whenNotRecommended'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductRecordToJson(_ProductRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'productName': instance.productName,
      'originalName': instance.originalName,
      'brand': instance.brand,
      'origin': instance.origin,
      'summary': instance.summary,
      'ingredients': instance.ingredients,
      'allergenAlerts': instance.allergenAlerts,
      'dietaryFlags': instance.dietaryFlags,
      'whenRecommended': instance.whenRecommended,
      'whenNotRecommended': instance.whenNotRecommended,
      'imagePaths': instance.imagePaths,
    };
