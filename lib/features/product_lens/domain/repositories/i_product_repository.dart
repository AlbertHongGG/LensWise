import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

abstract interface class IProductRepository extends ILocalStorageRepository<ProductRecord> {}
