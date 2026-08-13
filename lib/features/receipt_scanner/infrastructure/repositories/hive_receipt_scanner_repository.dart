import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_scanner_repository.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/models/receipt_scanner_hive_model.dart';

class HiveReceiptScannerRepository implements IReceiptScannerRepository {
  static const String boxName = 'receipt_scanner_records';
  late Box<ReceiptScannerHiveModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ReceiptScannerHiveModel>(boxName);
  }

  @override
  Future<List<ReceiptScannerRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  Future<ReceiptScannerRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ReceiptScannerRecord item) async {
    final model = ReceiptScannerHiveModel.fromDomain(item);
    await _box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<ReceiptScannerRecord?> get(String id) async {
    return getById(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
