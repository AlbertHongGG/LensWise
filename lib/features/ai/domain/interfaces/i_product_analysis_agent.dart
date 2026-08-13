import 'dart:typed_data';
import 'package:lens_wise/features/ai/domain/models/product_analysis_result.dart';

abstract class IProductAnalysisAgent {
  Future<ProductAnalysisResult> execute(List<Uint8List> input);
}
