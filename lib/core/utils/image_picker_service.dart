import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Provider for the ImagePickerService
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks a single image from the gallery.
  /// Returns the image as Uint8List, or null if canceled/failed.
  Future<Uint8List?> pickSingleImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image != null) {
        return await image.readAsBytes();
      }
    } catch (e) {
      // Log or handle error appropriately in a production app
      print('[ImagePickerService] Error picking single image: $e');
    }
    return null;
  }

  /// Picks multiple images from the gallery.
  /// [maxItems] can be used if supported, but image_picker pickMultiImage
  /// currently allows unlimited. We will truncate the list manually.
  Future<List<Uint8List>> pickMultipleImages({int maxItems = 2}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 100,
      );
      
      if (images.isNotEmpty) {
        final selectedImages = images.take(maxItems).toList();
        final List<Uint8List> bytesList = [];
        for (var img in selectedImages) {
          bytesList.add(await img.readAsBytes());
        }
        return bytesList;
      }
    } catch (e) {
      print('[ImagePickerService] Error picking multiple images: $e');
    }
    return [];
  }
}
