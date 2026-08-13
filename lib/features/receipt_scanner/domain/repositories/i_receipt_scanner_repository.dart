import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/repositories/hive_receipt_scanner_repository.dart';

import 'package:lens_wise/core/storage/i_local_storage_repository.dart';

abstract class IReceiptScannerRepository implements ILocalStorageRepository<ReceiptScannerRecord> {}
