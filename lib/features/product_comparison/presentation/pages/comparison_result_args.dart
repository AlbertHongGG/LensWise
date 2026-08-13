import 'dart:typed_data';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ProductComparisonRecordArgs {
  final ProductComparisonRecord result;
  
  // Can provide either raw memory images (from camera) or a saved local path (from history).
  final List<AppImageEntity>? rawImages;
  final String? imagePath;

  ProductComparisonRecordArgs({
    required this.result,
    this.rawImages,
    this.imagePath,
  });
}
