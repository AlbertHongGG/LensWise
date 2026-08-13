import 'package:hive/hive.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/domain/repositories/i_menu_scanner_repository.dart';
import 'package:lens_wise/features/menu_scanner/infrastructure/models/menu_scanner_hive_model.dart';

class HiveMenuScannerRepository implements IMenuScannerRepository {
  static const String boxName = 'menuScannerBox';

  Future<Box<MenuScannerHiveModel>> get _box async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return await Hive.openBox<MenuScannerHiveModel>(boxName);
      }
      return Hive.box<MenuScannerHiveModel>(boxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<MenuScannerHiveModel>(boxName);
    }
  }

  @override
  Future<void> init() async {
    await _box;
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    final keys = box.keys.cast<dynamic>().toList();
    for (var key in keys) {
      if (box.get(key)?.id == id) {
        await box.delete(key);
        return;
      }
    }
  }

  @override
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }

  @override
  Future<List<MenuScannerRecord>> getAll() async {
    final box = await _box;
    return box.values.map((e) => e.toDomain()).toList();
  }

  @override
  Future<MenuScannerRecord?> getById(String id) async {
    final box = await _box;
    try {
      return box.values.firstWhere((e) => e.id == id).toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(String id, MenuScannerRecord item) async {
    final box = await _box;
    final model = MenuScannerHiveModel.fromDomain(item);
    
    final keys = box.keys.cast<dynamic>().toList();
    for (var key in keys) {
      if (box.get(key)?.id == item.id) {
        await box.put(key, model);
        return;
      }
    }
    
    await box.add(model);
  }
}
