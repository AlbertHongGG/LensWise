import 'package:hive_flutter/hive_flutter.dart';
import 'i_local_storage_repository.dart';

class HiveRepository<T> implements ILocalStorageRepository<T> {
  final String boxName;
  Box<T>? _box;

  HiveRepository(this.boxName);

  @override
  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<T>(boxName);
    } else {
      _box = Hive.box<T>(boxName);
    }
  }

  @override
  Future<List<T>> getAll() async {
    await _ensureInitialized();
    return _box!.values.toList();
  }

  @override
  Future<T?> getById(String id) async {
    await _ensureInitialized();
    return _box!.get(id);
  }

  @override
  Future<void> save(String id, T item) async {
    await _ensureInitialized();
    await _box!.put(id, item);
  }

  @override
  Future<void> delete(String id) async {
    await _ensureInitialized();
    await _box!.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await _ensureInitialized();
    await _box!.clear();
  }

  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await init();
    }
  }
}
