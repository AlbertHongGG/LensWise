import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'panoramic_engine.dart';

class PanoramicStitcher {
  static Future<Uint8List?> stitchFrames(List<PanoramicFrame> frames) async {
    if (frames.isEmpty) return null;
    if (frames.length == 1) {
      return await compute(_encodeSingleFrame, frames.first);
    }
    
    return await compute(_stitchIsolate, frames);
  }

  static Uint8List? _encodeSingleFrame(PanoramicFrame frame) {
    try {
      final img.Image frameImg = img.Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: frame.highResBytes.buffer,
        bytesOffset: frame.highResBytes.offsetInBytes,
        rowStride: frame.bytesPerRow,
        numChannels: 3,
      );
      return img.encodeJpg(frameImg, quality: 90);
    } catch (e, stack) {
      debugPrint('Single encode error: $e\n$stack');
      throw Exception('Stitch Error: $e');
    }
  }

  static Uint8List? _stitchIsolate(List<PanoramicFrame> frames) {
    try {
      if (frames.isEmpty) return null;

      // Calculate Bounding Box
      int minX = 9999999;
      int minY = 9999999;
      int maxX = -9999999;
      int maxY = -9999999;

      for (final frame in frames) {
        if (frame.dx < minX) minX = frame.dx;
        if (frame.dy < minY) minY = frame.dy;
        if (frame.dx + frame.width > maxX) maxX = frame.dx + frame.width;
        if (frame.dy + frame.height > maxY) maxY = frame.dy + frame.height;
      }

      final int canvasWidth = maxX - minX;
      final int canvasHeight = maxY - minY;

      final img.Image canvas = img.Image(width: canvasWidth, height: canvasHeight, numChannels: 3);

      // Draw frames sequentially (latest frame overwrites previous at overlap)
      for (final frame in frames) {
        final img.Image frameImg = img.Image.fromBytes(
          width: frame.width,
          height: frame.height,
          bytes: frame.highResBytes.buffer,
          bytesOffset: frame.highResBytes.offsetInBytes,
          rowStride: frame.bytesPerRow,
          numChannels: 3,
        );

        final int dstX = frame.dx - minX;
        final int dstY = frame.dy - minY;

        img.compositeImage(canvas, frameImg, dstX: dstX, dstY: dstY);
      }

      return img.encodeJpg(canvas, quality: 85);
    } catch (e, stack) {
      debugPrint('Panoramic Stitching error: $e\n$stack');
      throw Exception('Stitch Error: $e');
    }
  }
}
