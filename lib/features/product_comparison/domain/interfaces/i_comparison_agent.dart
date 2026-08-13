import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

abstract class IComparisonAgent {
  Future<ComparisonResult> execute(List<Uint8List> input);
}
