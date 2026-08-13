import 'dart:typed_data';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';

abstract class IReceiptScannerAgent {
  Future<ReceiptScannerRecord> execute(List<Uint8List> input);
}
