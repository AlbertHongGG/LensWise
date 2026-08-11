import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/hive_repository.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

final localMediaServiceProvider = Provider<LocalMediaService>((ref) {
  return LocalMediaService();
});

final receiptRepositoryProvider = Provider<ILocalStorageRepository<ReceiptRecord>>((ref) {
  return HiveRepository<ReceiptRecord>('receipt_records_v4');
});

final productRepositoryProvider = Provider<ILocalStorageRepository<ProductRecord>>((ref) {
  return HiveRepository<ProductRecord>('product_records');
});

final comparisonRepositoryProvider = Provider<ILocalStorageRepository<ComparisonRecord>>((ref) {
  return HiveRepository<ComparisonRecord>('comparison_records_v2');
});
