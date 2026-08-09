import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

final receiptHistoryProvider = FutureProvider<List<ReceiptRecord>>((ref) async {
  final repo = ref.watch(receiptRepositoryProvider);
  final records = await repo.getAll();
  records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return records;
});

final productHistoryProvider = FutureProvider<List<ProductRecord>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final records = await repo.getAll();
  records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return records;
});

final comparisonHistoryProvider = FutureProvider<List<ComparisonRecord>>((ref) async {
  final repo = ref.watch(comparisonRepositoryProvider);
  final records = await repo.getAll();
  records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return records;
});
