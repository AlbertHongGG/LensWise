import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// A pipeline for asynchronous image processing, primarily handling WYSIWYG cropping.
class ImageProcessingPipeline {
  /// Crops the given [imageBytes] to exactly match the [targetAspectRatio].
  /// This operation runs in a background Isolate to prevent UI jank.
  /// 
  /// [targetAspectRatio] is typically `screenWidth / screenHeight`.
  static Future<Uint8List> cropToScreenRatio(Uint8List imageBytes, double targetAspectRatio) async {
    return await compute(_cropToRatioIsolate, {
      'bytes': imageBytes,
      'targetRatio': targetAspectRatio,
    });
  }
}

/// The isolated function that performs the mathematical symmetric crop.
Uint8List _cropToRatioIsolate(Map<String, dynamic> args) {
  final Uint8List bytes = args['bytes'];
  final double targetRatio = args['targetRatio'];

  // 1. Decode the original JPG/PNG image bytes
  final img.Image? original = img.decodeImage(bytes);
  if (original == null) {
    debugPrint('[ImageProcessingPipeline] Failed to decode image.');
    return bytes; // Return original if failed
  }

  final double originalRatio = original.width / original.height;
  
  // If the ratios are extremely close, don't waste time cropping
  if ((originalRatio - targetRatio).abs() < 0.01) {
    return bytes;
  }

  int cropW = original.width;
  int cropH = original.height;
  int offsetX = 0;
  int offsetY = 0;

  // Flutter's BoxFit.cover logic:
  // If the target ratio (e.g. 1080/2400 = 0.45) is LESS than the original ratio (e.g. 3000/4000 = 0.75),
  // it means the target is taller/narrower. BoxFit.cover will match the height and crop the left/right width.
  if (targetRatio < originalRatio) {
    cropH = original.height;
    cropW = (original.height * targetRatio).round();
    offsetX = ((original.width - cropW) / 2).round();
  } 
  // If the target ratio is GREATER, the target is wider/shorter. 
  // BoxFit.cover will match the width and crop the top/bottom height.
  else {
    cropW = original.width;
    cropH = (original.width / targetRatio).round();
    offsetY = ((original.height - cropH) / 2).round();
  }

  // 2. Perform the physical crop
  final img.Image croppedImage = img.copyCrop(
    original, 
    x: offsetX, 
    y: offsetY, 
    width: cropW, 
    height: cropH,
  );

  // 3. Encode back to JPG
  // Using quality 90 to preserve AI scanning details while saving file size
  return Uint8List.fromList(img.encodeJpg(croppedImage, quality: 90));
}
