import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

abstract class IProductComparisonAgent {
  Future<ProductComparisonRecord> execute(List<Uint8List> input);
}
