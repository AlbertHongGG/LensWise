import 'package:lens_wise/core/storage/i_local_storage_repository.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

abstract class IMenuScannerRepository extends ILocalStorageRepository<MenuScannerRecord> {}
