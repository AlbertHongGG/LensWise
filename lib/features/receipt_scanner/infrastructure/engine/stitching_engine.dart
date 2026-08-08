import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'image_utils.dart';

enum EngineState {
  searching,
  tracking,
  lost,
}

class StitchingEngine {
  EngineState _state = EngineState.searching;
  int _stitchedHeight = 0;
  
  EngineState get state => _state;
  int get totalStitchedHeight => _stitchedHeight;

  void reset() {
    _state = EngineState.searching;
    _stitchedHeight = 0;
  }

  Map<String, dynamic> processFrame(dynamic image) {
    if (state != EngineState.tracking) {
      return {'state': state, 'totalHeight': totalStitchedHeight};
    }
    
    return {'state': state, 'totalHeight': totalStitchedHeight};
  }
}
