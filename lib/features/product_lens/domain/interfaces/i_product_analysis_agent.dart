import 'dart:typed_data';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

abstract class IProductAnalysisAgent {
  Future<ProductRecord> execute(List<Uint8List> input);
}
