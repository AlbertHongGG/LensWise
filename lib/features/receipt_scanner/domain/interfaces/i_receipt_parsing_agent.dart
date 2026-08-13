import 'dart:typed_data';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

abstract class IReceiptParsingAgent {
  Future<ReceiptRecord> execute(List<Uint8List> input);
}
