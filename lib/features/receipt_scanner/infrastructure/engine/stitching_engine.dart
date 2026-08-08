import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'image_utils.dart';

enum EngineState {
  tracking,
  alignmentLost,
  recovering,
}

class StitchingEngine {
  EngineState state = EngineState.tracking;
  Int32List? lastValidSignature;
  
  // A threshold to determine if tracking is lost. 
  // If the error (SAD) exceeds this, we consider alignment lost.
  final double errorThreshold = 50.0;
  
  // Maximum allowed shift per frame. If it shifts more than this, 
  // the user moved too fast.
  final int maxShiftPerFrame = 200;

  // We accumulate the slices in memory. For simplicity, we just track the total stitched height.
  // In a full implementation, we'd append YUV bytes or Canvas drawings here.
  int totalStitchedHeight = 0;

  /// Processes a single incoming CameraImage frame.
  /// Returns the current state and any feedback (like shift amount).
  Map<String, dynamic> processFrame(CameraImage frame) {
    // 1. Extract 1D signature
    final Int32List currentSignature;
    try {
      currentSignature = ImageUtils.getVerticalSignature(frame);
    } catch (e) {
      return {'state': state, 'error': e.toString()};
    }

    if (lastValidSignature == null) {
      // First frame initialization
      lastValidSignature = currentSignature;
      totalStitchedHeight += frame.height; // Initial frame height
      return {'state': state, 'shift': 0, 'totalHeight': totalStitchedHeight};
    }

    // 2. Find displacement
    final displacement = ImageUtils.findDisplacement(
      lastValidSignature!, 
      currentSignature,
      maxShift: maxShiftPerFrame,
    );

    final int shift = displacement['shift'];
    final double error = displacement['error'];

    // 3. State Machine Logic
    switch (state) {
      case EngineState.tracking:
        if (error > errorThreshold || shift == maxShiftPerFrame) {
          // Tracking lost (moved too fast, blurred, or completely changed)
          state = EngineState.alignmentLost;
        } else {
          // Valid tracking!
          if (shift > 0) {
            totalStitchedHeight += shift;
            lastValidSignature = currentSignature;
            
            // TODO: Extract the 'shift' height of pixels from 'frame' 
            // and append to our master stitched image buffer.
          }
        }
        break;

      case EngineState.alignmentLost:
      case EngineState.recovering:
        // We are lost. User needs to move the phone back to match `lastValidSignature`.
        // If the new frame matches the old signature well, we recover.
        // For recovery, we might allow a slightly larger error threshold, 
        // and we expect shift to be near 0 if they aligned it correctly.
        if (error < errorThreshold && shift.abs() < 50) {
          state = EngineState.tracking;
          lastValidSignature = currentSignature; // Update to the new stable frame
        } else {
          state = EngineState.recovering;
        }
        break;
    }

    return {
      'state': state,
      'shift': shift,
      'error': error,
      'totalHeight': totalStitchedHeight,
    };
  }

  /// Resets the engine for a new scan session
  void reset() {
    state = EngineState.tracking;
    lastValidSignature = null;
    totalStitchedHeight = 0;
  }
}
