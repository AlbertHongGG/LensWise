import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/repositories/hive_receipt_scanner_repository.dart';

abstract class IReceiptScannerRepository {
  Future<void> save(String id, ReceiptScannerRecord record);
  Future<ReceiptScannerRecord?> get(String id);
  Future<List<ReceiptScannerRecord>> getAll();
  Future<void> delete(String id);
}
