import 'dart:typed_data';
import 'package:camera/camera.dart';

class ImageUtils {
  /// Extracts a 1D vertical signature (projection profile) from a CameraImage.
  /// We extract a central column of width [sliceWidth] and sum the pixel brightness 
  /// horizontally for each row.
  /// This drastically reduces a 2D image problem into a 1D signal processing problem.
  static Int32List getVerticalSignature(CameraImage image, {int sliceWidth = 100}) {
    final int height = image.height;
    final int width = image.width;
    final Int32List signature = Int32List(height);

    // Ensure we don't exceed bounds
    final int safeSliceWidth = sliceWidth > width ? width : sliceWidth;
    final int startX = (width - safeSliceWidth) ~/ 2;

    if (image.format.group == ImageFormatGroup.yuv420) {
      // YUV420: Plane 0 is the Y (luminance) plane, exactly what we want.
      final Plane yPlane = image.planes[0];
      final int rowStride = yPlane.bytesPerRow;
      final int pixelStride = yPlane.bytesPerPixel ?? 1;
      final Uint8List bytes = yPlane.bytes;

      for (int y = 0; y < height; y++) {
        int rowSum = 0;
        final int rowOffset = y * rowStride;
        for (int x = 0; x < safeSliceWidth; x++) {
          final int pixelOffset = rowOffset + (startX + x) * pixelStride;
          rowSum += bytes[pixelOffset];
        }
        signature[y] = rowSum;
      }
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      // BGRA8888 (iOS): Single plane, 4 bytes per pixel.
      final Plane plane = image.planes[0];
      final int rowStride = plane.bytesPerRow;
      final Uint8List bytes = plane.bytes;

      for (int y = 0; y < height; y++) {
        int rowSum = 0;
        final int rowOffset = y * rowStride;
        for (int x = 0; x < safeSliceWidth; x++) {
          final int pixelOffset = rowOffset + (startX + x) * 4;
          // Simple luminance approximation: G channel or average
          // BGRA -> bytes[0]=B, bytes[1]=G, bytes[2]=R
          // We'll use G channel for speed, it correlates highly with luminance.
          rowSum += bytes[pixelOffset + 1]; 
        }
        signature[y] = rowSum;
      }
    } else {
      // Fallback or unsupported format
      throw UnsupportedError('Unsupported image format: ${image.format.group}');
    }

    return signature;
  }

  /// Finds the vertical displacement (ΔY) between the previous signature and current signature.
  /// [maxShift] is the maximum expected movement between frames.
  /// Returns a map with 'shift': the ΔY pixels, and 'error': the SAD error score.
  /// If the error is too high, it implies tracking is lost.
  static Map<String, dynamic> findDisplacement(
      Int32List prevSignature, 
      Int32List currentSignature, 
      {int maxShift = 400}) {
    
    if (prevSignature.length != currentSignature.length) {
      return {'shift': 0, 'error': double.infinity};
    }

    final int height = prevSignature.length;
    int bestShift = 0;
    double minError = double.infinity;

    // We assume the camera moves DOWN along the receipt, 
    // which means the NEW frame shows content from lower down on the receipt.
    // So the top of the NEW frame matches some lower part of the PREVIOUS frame.
    // So `currentSignature[y]` should match `prevSignature[y + shift]`.
    // To be safe, we search a range (e.g. -50 to +maxShift) to handle slight upward jitters.
    final int searchMin = -50;
    final int searchMax = maxShift;

    for (int shift = searchMin; shift <= searchMax; shift++) {
      int sad = 0;
      int count = 0;

      for (int y = 0; y < height; y++) {
        final int prevY = y + shift;
        if (prevY >= 0 && prevY < height) {
          sad += (currentSignature[y] - prevSignature[prevY]).abs();
          count++;
        }
      }

      if (count > 0) {
        final double avgError = sad / count;
        if (avgError < minError) {
          minError = avgError;
          bestShift = shift;
        }
      }
    }

    return {
      'shift': bestShift,
      'error': minError,
    };
  }
}
