import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

abstract interface class IReceiptRepository extends ILocalStorageRepository<ReceiptRecord> {}
