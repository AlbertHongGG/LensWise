import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonResultArgs {
  final ComparisonResult result;
  
  // Can provide either raw memory images (from camera) or a saved local path (from history).
  final List<Uint8List>? rawImages;
  final String? imagePath;

  ComparisonResultArgs({
    required this.result,
    this.rawImages,
    this.imagePath,
  });
}
