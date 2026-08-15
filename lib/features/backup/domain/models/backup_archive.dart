import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

part 'backup_archive.freezed.dart';
part 'backup_archive.g.dart';

@freezed
abstract class BackupArchive with _$BackupArchive {
  const factory BackupArchive({
    required DateTime exportedAt,
    required String appVersion,
    @Default([]) List<ReceiptScannerRecord> receiptRecords,
    @Default([]) List<ProductLensRecord> productLensRecords,
    @Default([]) List<ProductComparisonRecord> comparisonRecords,
    @Default([]) List<MenuScannerRecord> menuRecords,
  }) = _BackupArchive;

  factory BackupArchive.fromJson(Map<String, dynamic> json) => _$BackupArchiveFromJson(json);
}
