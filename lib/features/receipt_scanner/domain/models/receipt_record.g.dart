// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => _ReceiptItem(
  originalName: json['originalName'] as String,
  translatedName: json['translatedName'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$ReceiptItemToJson(_ReceiptItem instance) =>
    <String, dynamic>{
      'originalName': instance.originalName,
      'translatedName': instance.translatedName,
      'price': instance.price,
    };

_ReceiptFeeItem _$ReceiptFeeItemFromJson(Map<String, dynamic> json) =>
    _ReceiptFeeItem(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ReceiptFeeItemToJson(_ReceiptFeeItem instance) =>
    <String, dynamic>{'name': instance.name, 'amount': instance.amount};

_ReceiptRecord _$ReceiptRecordFromJson(Map<String, dynamic> json) =>
    _ReceiptRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      receiptDate: json['receiptDate'] as String?,
      storeName: json['storeName'] as String?,
      currency: json['currency'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      discounts:
          (json['discounts'] as List<dynamic>?)
              ?.map((e) => ReceiptFeeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      taxes:
          (json['taxes'] as List<dynamic>?)
              ?.map((e) => ReceiptFeeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      imagePaths:
          (json['imagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ReceiptRecordToJson(_ReceiptRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'receiptDate': instance.receiptDate,
      'storeName': instance.storeName,
      'currency': instance.currency,
      'subtotal': instance.subtotal,
      'items': instance.items,
      'discounts': instance.discounts,
      'taxes': instance.taxes,
      'totalAmount': instance.totalAmount,
      'imagePaths': instance.imagePaths,
    };
