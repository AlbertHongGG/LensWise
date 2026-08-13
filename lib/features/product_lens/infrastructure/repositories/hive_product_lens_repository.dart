import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/domain/repositories/i_product_lens_repository.dart';
import 'package:lens_wise/features/product_lens/infrastructure/models/product_lens_hive_model.dart';

class HiveProductLensRepository implements IProductLensRepository {
  static const String boxName = 'product_records';
  Future<Box<ProductLensHiveModel>> get _box async {
    if (!Hive.isBoxOpen(boxName)) {
      try {
        return await Hive.openBox<ProductLensHiveModel>(boxName);
      } catch (e) {
        // Handle schema mismatch or corruption by clearing the box
        await Hive.deleteBoxFromDisk(boxName);
        return await Hive.openBox<ProductLensHiveModel>(boxName);
      }
    }
    return Hive.box<ProductLensHiveModel>(boxName);
  }

  @override
  Future<void> init() async {
    await _box;
  }

  @override
  Future<List<ProductLensRecord>> getAll() async {
    final box = await _box;
    return box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ProductLensRecord?> getById(String id) async {
    final box = await _box;
    final model = box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ProductLensRecord item) async {
    final box = await _box;
    final model = ProductLensHiveModel.fromDomain(item);
    await box.put(id, model);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<ProductLensRecord?> get(String id) async {
    return getById(id);
  }

  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}
