import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_product_comparison_repository.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/models/product_comparison_hive_model.dart';

class HiveProductComparisonRepository implements IProductComparisonRepository {
  static const String boxName = 'product_comparison_records';
  Future<Box<ProductComparisonHiveModel>> get _box async {
    if (!Hive.isBoxOpen(boxName)) {
      try {
        return await Hive.openBox<ProductComparisonHiveModel>(boxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(boxName);
        return await Hive.openBox<ProductComparisonHiveModel>(boxName);
      }
    }
    return Hive.box<ProductComparisonHiveModel>(boxName);
  }

  @override
  Future<void> init() async {
    await _box;
  }

  @override
  Future<List<ProductComparisonRecord>> getAll() async {
    final box = await _box;
    return box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ProductComparisonRecord?> getById(String id) async {
    final box = await _box;
    final model = box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ProductComparisonRecord item) async {
    final box = await _box;
    final model = ProductComparisonHiveModel.fromDomain(item);
    await box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }


  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}
