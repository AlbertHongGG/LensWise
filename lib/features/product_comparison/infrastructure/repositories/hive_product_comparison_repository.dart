import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_product_comparison_repository.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/models/product_comparison_hive_model.dart';

class HiveProductComparisonRepository implements IProductComparisonRepository {
  static const String boxName = 'product_comparison_records';
  late Box<ProductComparisonHiveModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ProductComparisonHiveModel>(boxName);
  }

  @override
  Future<List<ProductComparisonRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  Future<ProductComparisonRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ProductComparisonRecord item) async {
    final model = ProductComparisonHiveModel.fromDomain(item);
    await _box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<ProductComparisonRecord?> get(String id) async {
    return getById(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
