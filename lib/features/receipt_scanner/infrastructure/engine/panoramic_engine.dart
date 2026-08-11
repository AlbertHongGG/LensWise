import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:camerawesome/camerawesome_plugin.dart';

enum PanoramicState { tracking, alignmentLost }

class PanoramicFrame {
  final Uint8List highResBytes;
  final int width;
  final int height;
  final int bytesPerRow;
  final int dx;
  final int dy;

  PanoramicFrame({
    required this.highResBytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.dx,
    required this.dy,
  });
}

class PanoramicEngine {
  PanoramicState state = PanoramicState.tracking;
  final List<PanoramicFrame> _bufferedFrames = [];
  
  img.Image? _prevLowRes;
  int _currentX = 0;
  int _currentY = 0;
  
  // Total tracked canvas dimension boundaries
  int minX = 0;
  int maxX = 0;
  int minY = 0;
  int maxY = 0;

  // Track the approximate stitched height for UI progress
  int _stitchedHeight = 0;
  
  // Save a new frame when accumulated movement exceeds 15% of frame dimension
  static const double _saveThreshold = 0.15;

  // Downscale width for fast 2D tracking
  static const int _trackWidth = 100;

  List<PanoramicFrame> get bufferedFrames => _bufferedFrames;

  void reset() {
    state = PanoramicState.tracking;
    _bufferedFrames.clear();
    _prevLowRes = null;
    _currentX = 0;
    _currentY = 0;
    _stitchedHeight = 0;
    minX = 0;
    maxX = 0;
    minY = 0;
    maxY = 0;
  }

  Map<String, dynamic> processFrame(dynamic frame) {
    if (state == PanoramicState.alignmentLost) {
      return {'state': state, 'totalHeight': _stitchedHeight};
    }

    try {
      // 1. Convert to standardized grayscale img.Image
      final rawImage = _extractYChannel(frame);
      if (rawImage == null) return {'state': state, 'totalHeight': _stitchedHeight};

      // 2. Downscale for real-time tracking in Dart
      final lowRes = img.copyResize(rawImage, width: _trackWidth);
      final double scaleFactor = rawImage.width / _trackWidth;

      if (_prevLowRes == null) {
        _prevLowRes = lowRes;
        _stitchedHeight = rawImage.height;
        _saveFrame(rawImage, 0, 0);
        return {'state': state, 'totalHeight': _stitchedHeight};
      }

      // 3. 2D Block Matching
      final displacement = _find2DDisplacement(_prevLowRes!, lowRes);
      
      if (displacement == null) {
        state = PanoramicState.alignmentLost;
        return {'state': state, 'totalHeight': _stitchedHeight};
      }

      final int dxLow = displacement['dx'];
      final int dyLow = displacement['dy'];

      // Scale back to high-res coordinates
      final int dxHigh = (dxLow * scaleFactor).round();
      final int dyHigh = (dyLow * scaleFactor).round();

      // Accumulate relative movement.
      // Note: If previous frame's block is at (x+dx, y+dy) in current frame,
      // it means the CURRENT frame is shifted by (-dx, -dy) relative to previous.
      // So absolute coordinate of current frame is currentX - dxHigh.
      _currentX -= dxHigh;
      _currentY -= dyHigh;

      final lastSaved = _bufferedFrames.last;
      final int diffX = (_currentX - lastSaved.dx).abs();
      final int diffY = (_currentY - lastSaved.dy).abs();
      
      final int requiredMovementX = (rawImage.width * _saveThreshold).round();
      final int requiredMovementY = (rawImage.height * _saveThreshold).round();
      
      if (diffY > requiredMovementY || diffX > requiredMovementX) {
        _saveFrame(rawImage, _currentX, _currentY);
        // Calculate max vertical span for UI
        _stitchedHeight = (maxY - minY);
      }

      _prevLowRes = lowRes;

      return {'state': state, 'totalHeight': _stitchedHeight};
    } catch (e) {
      return {'state': state, 'error': e.toString(), 'totalHeight': _stitchedHeight};
    }
  }

  void _saveFrame(img.Image rawImage, int dx, int dy) {
    final frame = PanoramicFrame(
      dx: dx,
      dy: dy,
      width: rawImage.width,
      height: rawImage.height,
      highResBytes: rawImage.getBytes(),
      bytesPerRow: rawImage.rowStride,
    );
    _bufferedFrames.add(frame);
    if (_bufferedFrames.length > 500) {
      _bufferedFrames.removeAt(0);
    }
    
    if (dx < minX) minX = dx;
    if (dy < minY) minY = dy;
    if (dx + rawImage.width > maxX) maxX = dx + rawImage.width;
    if (dy + rawImage.height > maxY) maxY = dy + rawImage.height;
  }

  img.Image? _extractYChannel(dynamic frame) {
    img.Image? gray;
    if (frame is Nv21Image) {
      final yPlane = frame.planes[0];
      gray = img.Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: yPlane.bytes.buffer,
        bytesOffset: yPlane.bytes.offsetInBytes,
        rowStride: yPlane.bytesPerRow,
        numChannels: 1,
      );
    } else if (frame is Yuv420Image) {
      final yPlane = frame.planes[0];
      gray = img.Image.fromBytes(
        width: frame.width,
        height: frame.height,
        bytes: yPlane.bytes.buffer,
        bytesOffset: yPlane.bytes.offsetInBytes,
        rowStride: yPlane.bytesPerRow,
        numChannels: 1,
      );
    } else if (frame is Bgra8888Image) {
      final bgraBytes = frame.planes[0].bytes;
      final w = frame.width;
      final h = frame.height;
      gray = img.Image(width: w, height: h, numChannels: 1);
      final int bytesPerRow = frame.planes[0].bytesPerRow;
      
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final offset = y * bytesPerRow + x * 4;
          final b = bgraBytes[offset];
          final g = bgraBytes[offset + 1];
          final r = bgraBytes[offset + 2];
          final lum = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
          gray.setPixelR(x, y, lum);
        }
      }
    } else {
      throw Exception('Unrecognized frame format: ${frame.runtimeType}');
    }

    // Phase 2: Convert to 3-channel RGB grayscale (prevents RED interpretation in JPEG encoder)
    if (gray.numChannels == 1) {
      gray = gray.convert(numChannels: 3);
    }

    // Phase 1: Apply physical sensor rotation to normalize tracking vectors
    if (frame is AnalysisImage) {
      int angle = 0;
      switch (frame.rotation) {
        case InputAnalysisImageRotation.rotation90deg: angle = 90; break;
        case InputAnalysisImageRotation.rotation180deg: angle = 180; break;
        case InputAnalysisImageRotation.rotation270deg: angle = 270; break;
        default: angle = 0;
      }
      if (angle != 0) {
        gray = img.copyRotate(gray, angle: angle);
      }
    }

    return gray;
  }

  Map<String, dynamic>? _find2DDisplacement(img.Image prev, img.Image curr) {
    // Define a template block from the center of previous frame
    final int blockW = (prev.width * 0.4).round();
    final int blockH = (prev.height * 0.2).round();
    final int startX = (prev.width - blockW) ~/ 2;
    final int startY = (prev.height - blockH) ~/ 2;

    // Search window in current frame
    final int maxDx = (prev.width * 0.15).round();
    final int maxDy = (prev.height * 0.35).round();

    int bestSad = 999999999;
    int bestDx = 0;
    int bestDy = 0;

    for (int dy = -maxDy; dy <= maxDy; dy++) {
      for (int dx = -maxDx; dx <= maxDx; dx++) {
        int sad = 0;
        bool outOfBounds = false;
        
        for (int y = 0; y < blockH; y += 2) { // step by 2 to speed up
          for (int x = 0; x < blockW; x += 2) {
            final px = startX + x;
            final py = startY + y;
            final cx = px + dx;
            final cy = py + dy;

            if (cx < 0 || cy < 0 || cx >= curr.width || cy >= curr.height) {
              outOfBounds = true;
              break;
            }
            
            final valP = prev.getPixel(px, py).r;
            final valC = curr.getPixel(cx, cy).r;
            sad += (valP - valC).abs().toInt();
          }
          if (outOfBounds) break;
        }
        
        if (!outOfBounds && sad < bestSad) {
          bestSad = sad;
          bestDx = dx;
          bestDy = dy;
        }
      }
    }

    final int count = (blockW ~/ 2) * (blockH ~/ 2);
    final double avgError = bestSad / count;

    // If avg pixel difference > 35, tracking is lost
    if (avgError > 35.0) return null;

    return {'dx': bestDx, 'dy': bestDy};
  }
}
