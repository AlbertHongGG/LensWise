import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_repository.dart';
import 'package:lens_wise/features/product_lens/infrastructure/models/product_hive_model.dart';

class HiveProductRepository implements IProductRepository {
  static const String boxName = 'product_records';
  late Box<ProductHiveModel> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<ProductHiveModel>(boxName);
  }

  @override
  Future<List<ProductRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ProductRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ProductRecord item) async {
    final model = ProductHiveModel.fromDomain(item);
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
