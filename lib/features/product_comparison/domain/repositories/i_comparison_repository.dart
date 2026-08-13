import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

abstract interface class IComparisonRepository extends ILocalStorageRepository<ComparisonRecord> {}
