import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_scanner_repository.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/models/receipt_scanner_hive_model.dart';

class HiveReceiptScannerRepository implements IReceiptScannerRepository {
  static const String boxName = 'receipt_scanner_records';
  Future<Box<ReceiptScannerHiveModel>> get _box async {
    if (!Hive.isBoxOpen(boxName)) {
      try {
        return await Hive.openBox<ReceiptScannerHiveModel>(boxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(boxName);
        return await Hive.openBox<ReceiptScannerHiveModel>(boxName);
      }
    }
    return Hive.box<ReceiptScannerHiveModel>(boxName);
  }

  @override
  Future<void> init() async {
    await _box;
  }

  @override
  Future<List<ReceiptScannerRecord>> getAll() async {
    final box = await _box;
    return box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ReceiptScannerRecord?> getById(String id) async {
    final box = await _box;
    final model = box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ReceiptScannerRecord item) async {
    final box = await _box;
    final model = ReceiptScannerHiveModel.fromDomain(item);
    await box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<ReceiptScannerRecord?> get(String id) async {
    return getById(id);
  }

  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}
