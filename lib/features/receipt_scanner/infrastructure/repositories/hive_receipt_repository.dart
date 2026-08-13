import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/repositories/i_receipt_repository.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/models/receipt_hive_model.dart';

class HiveReceiptRepository implements IReceiptRepository {
  static const String boxName = 'receipt_records';
  late Box<ReceiptHiveModel> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<ReceiptHiveModel>(boxName);
  }

  @override
  Future<List<ReceiptRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ReceiptRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ReceiptRecord item) async {
    final model = ReceiptHiveModel.fromDomain(item);
    await _box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
  }
}
