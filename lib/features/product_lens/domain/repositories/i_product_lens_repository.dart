import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/infrastructure/repositories/hive_product_lens_repository.dart';

abstract class IProductLensRepository {
  Future<void> save(String id, ProductLensRecord record);
  Future<ProductLensRecord?> get(String id);
  Future<List<ProductLensRecord>> getAll();
  Future<void> delete(String id);
}
