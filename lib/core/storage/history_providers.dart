import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/record_manager_service.dart';
import 'package:lens_wise/features/history/domain/controllers/i_history_controller.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

class ReceiptHistoryController extends AsyncNotifier<List<ReceiptScannerRecord>> implements IHistoryController {
  @override
  Future<List<ReceiptScannerRecord>> build() async {
    final repo = ref.watch(receiptScannerRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(receiptScannerRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(receiptScannerRepositoryProvider);
    final manager = ref.read(recordManagerServiceProvider);
    final records = await repo.getAll();
    for (final r in records) {
      await manager.deleteRecord(
        repository: repo,
        id: r.id,
        imagePaths: r.deletionImagePaths,
        imagePath: r.deletionImagePath,
      );
    }
    ref.invalidateSelf();
  }
}

final receiptHistoryProvider = AsyncNotifierProvider<ReceiptHistoryController, List<ReceiptScannerRecord>>(
  () => ReceiptHistoryController(),
);

class ProductHistoryController extends AsyncNotifier<List<ProductLensRecord>> implements IHistoryController {
  @override
  Future<List<ProductLensRecord>> build() async {
    final repo = ref.watch(productLensRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(productLensRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(productLensRepositoryProvider);
    final manager = ref.read(recordManagerServiceProvider);
    final records = await repo.getAll();
    for (final r in records) {
      await manager.deleteRecord(
        repository: repo,
        id: r.id,
        imagePaths: r.deletionImagePaths,
        imagePath: r.deletionImagePath,
      );
    }
    ref.invalidateSelf();
  }
}

final productHistoryProvider = AsyncNotifierProvider<ProductHistoryController, List<ProductLensRecord>>(
  () => ProductHistoryController(),
);

class ComparisonHistoryController extends AsyncNotifier<List<ProductComparisonRecord>> implements IHistoryController {
  @override
  Future<List<ProductComparisonRecord>> build() async {
    final repo = ref.watch(productComparisonRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(productComparisonRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(productComparisonRepositoryProvider);
    final manager = ref.read(recordManagerServiceProvider);
    final records = await repo.getAll();
    for (final r in records) {
      await manager.deleteRecord(
        repository: repo,
        id: r.id,
        imagePaths: r.deletionImagePaths,
        imagePath: r.deletionImagePath,
      );
    }
    ref.invalidateSelf();
  }
}

final comparisonHistoryProvider = AsyncNotifierProvider<ComparisonHistoryController, List<ProductComparisonRecord>>(
  () => ComparisonHistoryController(),
);
