import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_result.dart';

class ProductComparisonResultArgs {
  final ProductComparisonResult result;
  
  // Can provide either raw memory images (from camera) or a saved local path (from history).
  final List<Uint8List>? rawImages;
  final String? imagePath;

  ProductComparisonResultArgs({
    required this.result,
    this.rawImages,
    this.imagePath,
  });
}
