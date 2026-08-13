import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/repositories/hive_product_comparison_repository.dart';

import 'package:lens_wise/core/storage/i_local_storage_repository.dart';

abstract class IProductComparisonRepository implements ILocalStorageRepository<ProductComparisonRecord> {}
