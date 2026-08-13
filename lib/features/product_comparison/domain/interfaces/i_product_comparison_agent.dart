import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_result.dart';

abstract class IProductComparisonAgent {
  Future<ProductComparisonResult> execute(List<Uint8List> input);
}
