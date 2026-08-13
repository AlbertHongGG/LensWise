import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_scanner_repository.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/repositories/hive_receipt_scanner_repository.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_lens_repository.dart';
import 'package:lens_wise/features/product_lens/infrastructure/repositories/hive_product_lens_repository.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_product_comparison_repository.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/repositories/hive_product_comparison_repository.dart';

final localMediaServiceProvider = Provider<LocalMediaService>((ref) {
  return LocalMediaService();
});

final receiptScannerRepositoryProvider = Provider<IReceiptScannerRepository>((ref) {
  return HiveReceiptScannerRepository();
});

final productLensRepositoryProvider = Provider<IProductLensRepository>((ref) {
  return HiveProductLensRepository();
});

final productComparisonRepositoryProvider = Provider<IProductComparisonRepository>((ref) {
  return HiveProductComparisonRepository();
});
