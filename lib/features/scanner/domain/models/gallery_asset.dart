import 'dart:typed_data';
import 'package:flutter/material.dart';

abstract class GalleryAsset {
  final String id;
  final DateTime createDateTime;

  GalleryAsset({
    required this.id,
    required this.createDateTime,
  });

  Future<Uint8List?> get originBytes;
  
  /// Returns an ImageProvider for the thumbnail, abstracting away the underlying plugin.
  ImageProvider getThumbnailProvider({int size = 250});
}
