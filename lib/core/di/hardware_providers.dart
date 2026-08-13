import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/scanner/domain/interfaces/i_camera_service.dart';
import 'package:lens_wise/features/scanner/domain/interfaces/i_gallery_service.dart';
import 'package:lens_wise/core/interfaces/i_image_picker_service.dart';

final cameraServiceProvider = Provider<ICameraService>((ref) {
  throw UnimplementedError('cameraServiceProvider has not been initialized');
});

final galleryServiceProvider = Provider<IGalleryService>((ref) {
  throw UnimplementedError('galleryServiceProvider has not been initialized');
});

final imagePickerServiceProvider = Provider<IImagePickerService>((ref) {
  throw UnimplementedError('imagePickerServiceProvider has not been initialized');
});
