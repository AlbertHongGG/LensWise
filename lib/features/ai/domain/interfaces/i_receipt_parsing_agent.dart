import 'dart:typed_data';
import 'package:lens_wise/features/ai/domain/models/receipt_parsing_result.dart';

abstract class IReceiptParsingAgent {
  Future<ReceiptParsingResult> execute(List<Uint8List> input);
}
