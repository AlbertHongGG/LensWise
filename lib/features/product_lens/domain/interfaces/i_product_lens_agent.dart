import 'dart:typed_data';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

abstract class IProductLensAgent {
  Future<ProductLensRecord> execute(List<Uint8List> input);
}
