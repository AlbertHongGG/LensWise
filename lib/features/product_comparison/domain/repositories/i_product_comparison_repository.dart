import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/core/storage/i_local_storage_repository.dart';

abstract class IProductComparisonRepository implements ILocalStorageRepository<ProductComparisonRecord> {}
