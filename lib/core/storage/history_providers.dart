import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/storage/record_manager_service.dart';
import 'package:lens_wise/features/history/domain/controllers/i_history_controller.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

class ReceiptHistoryController extends AsyncNotifier<List<ReceiptRecord>> implements IHistoryController {
  @override
  Future<List<ReceiptRecord>> build() async {
    final repo = ref.watch(receiptRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(receiptRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(receiptRepositoryProvider);
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

final receiptHistoryProvider = AsyncNotifierProvider<ReceiptHistoryController, List<ReceiptRecord>>(
  () => ReceiptHistoryController(),
);

class ProductHistoryController extends AsyncNotifier<List<ProductRecord>> implements IHistoryController {
  @override
  Future<List<ProductRecord>> build() async {
    final repo = ref.watch(productRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(productRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(productRepositoryProvider);
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

final productHistoryProvider = AsyncNotifierProvider<ProductHistoryController, List<ProductRecord>>(
  () => ProductHistoryController(),
);

class ComparisonHistoryController extends AsyncNotifier<List<ComparisonRecord>> implements IHistoryController {
  @override
  Future<List<ComparisonRecord>> build() async {
    final repo = ref.watch(comparisonRepositoryProvider);
    final records = await repo.getAll();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<void> deleteRecord(IHistoryRecord record) async {
    final manager = ref.read(recordManagerServiceProvider);
    await manager.deleteRecord(
      repository: ref.read(comparisonRepositoryProvider),
      id: record.id,
      imagePaths: record.deletionImagePaths,
      imagePath: record.deletionImagePath,
    );
    ref.invalidateSelf();
  }

  @override
  Future<void> clearAll() async {
    final repo = ref.read(comparisonRepositoryProvider);
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

final comparisonHistoryProvider = AsyncNotifierProvider<ComparisonHistoryController, List<ComparisonRecord>>(
  () => ComparisonHistoryController(),
);
