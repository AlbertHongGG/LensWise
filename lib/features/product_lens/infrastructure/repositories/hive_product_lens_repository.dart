import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_lens_repository.dart';
import 'package:lens_wise/features/product_lens/infrastructure/models/product_lens_hive_model.dart';

class HiveProductLensRepository implements IProductLensRepository {
  static const String boxName = 'product_records';
  late Box<ProductLensHiveModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ProductLensHiveModel>(boxName);
  }

  @override
  Future<List<ProductLensRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  Future<ProductLensRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ProductLensRecord item) async {
    final model = ProductLensHiveModel.fromDomain(item);
    await _box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<ProductLensRecord?> get(String id) async {
    return getById(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
