import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/repositories/hive_product_comparison_repository.dart';

abstract class IProductComparisonRepository {
  Future<void> save(String id, ProductComparisonRecord record);
  Future<ProductComparisonRecord?> get(String id);
  Future<List<ProductComparisonRecord>> getAll();
  Future<void> delete(String id);
}
