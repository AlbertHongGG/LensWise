import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/infrastructure/repositories/hive_product_lens_repository.dart';

import 'package:lens_wise/core/storage/i_local_storage_repository.dart';

abstract class IProductLensRepository implements ILocalStorageRepository<ProductLensRecord> {}
