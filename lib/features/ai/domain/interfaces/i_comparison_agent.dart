import 'dart:typed_data';
import 'package:lens_wise/features/ai/domain/models/product_comparison_result.dart';

abstract class IComparisonAgent {
  Future<ProductComparisonResult> execute(List<Uint8List> input);
}
