// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_archive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BackupArchive _$BackupArchiveFromJson(
  Map<String, dynamic> json,
) => _BackupArchive(
  exportedAt: DateTime.parse(json['exportedAt'] as String),
  appVersion: json['appVersion'] as String,
  receiptRecords:
      (json['receiptRecords'] as List<dynamic>?)
          ?.map((e) => ReceiptScannerRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  productLensRecords:
      (json['productLensRecords'] as List<dynamic>?)
          ?.map((e) => ProductLensRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  comparisonRecords:
      (json['comparisonRecords'] as List<dynamic>?)
          ?.map(
            (e) => ProductComparisonRecord.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  menuRecords:
      (json['menuRecords'] as List<dynamic>?)
          ?.map((e) => MenuScannerRecord.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BackupArchiveToJson(_BackupArchive instance) =>
    <String, dynamic>{
      'exportedAt': instance.exportedAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'receiptRecords': instance.receiptRecords,
      'productLensRecords': instance.productLensRecords,
      'comparisonRecords': instance.comparisonRecords,
      'menuRecords': instance.menuRecords,
    };
