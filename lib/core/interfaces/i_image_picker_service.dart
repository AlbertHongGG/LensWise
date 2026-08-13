import 'dart:typed_data';

abstract class IImagePickerService {
  Future<Uint8List?> pickSingleImage();
  Future<List<Uint8List>> pickMultipleImages({int maxItems = 2});
}
