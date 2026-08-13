import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:lens_wise/core/interfaces/i_image_picker_service.dart';

class ImagePickerService implements IImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
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
      print('[ImagePickerService] Error picking single image: $e');
    }
    return null;
  }

  @override
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
