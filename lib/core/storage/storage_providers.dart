import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/local_media_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_repository.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/repositories/hive_receipt_repository.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_repository.dart';
import 'package:lens_wise/features/product_lens/infrastructure/repositories/hive_product_repository.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_comparison_repository.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/repositories/hive_comparison_repository.dart';

final localMediaServiceProvider = Provider<LocalMediaService>((ref) {
  return LocalMediaService();
});

final receiptRepositoryProvider = Provider<IReceiptRepository>((ref) {
  return HiveReceiptRepository();
});

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return HiveProductRepository();
});

final comparisonRepositoryProvider = Provider<IComparisonRepository>((ref) {
  return HiveComparisonRepository();
});
