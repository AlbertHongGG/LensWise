import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';
import 'package:lens_wise/features/product_comparison/domain/repositories/i_comparison_repository.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/models/comparison_hive_model.dart';

class HiveComparisonRepository implements IComparisonRepository {
  static const String boxName = 'comparison_records';
  late Box<ComparisonHiveModel> _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<ComparisonHiveModel>(boxName);
  }

  @override
  Future<List<ComparisonRecord>> getAll() async {
    return _box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<ComparisonRecord?> getById(String id) async {
    final model = _box.get(id);
    return model?.toDomain();
  }

  @override
  Future<void> save(String id, ComparisonRecord item) async {
    final model = ComparisonHiveModel.fromDomain(item);
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
