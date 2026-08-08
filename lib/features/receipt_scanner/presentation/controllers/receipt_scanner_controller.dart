import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/engine/stitching_engine.dart';

class ReceiptScannerState {
  final EngineState engineState;
  final int stitchedHeight;
  final String? errorMessage;
  final bool isScanning;

  ReceiptScannerState({
    this.engineState = EngineState.tracking,
    this.stitchedHeight = 0,
    this.errorMessage,
    this.isScanning = false,
  });

  ReceiptScannerState copyWith({
    EngineState? engineState,
    int? stitchedHeight,
    String? errorMessage,
    bool? isScanning,
  }) {
    return ReceiptScannerState(
      engineState: engineState ?? this.engineState,
      stitchedHeight: stitchedHeight ?? this.stitchedHeight,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class ReceiptScannerController extends Notifier<ReceiptScannerState> {
  late final StitchingEngine _engine;
  
  // To avoid processing 30fps and blocking main thread, we throttle frame processing
  DateTime _lastProcessTime = DateTime.now();

  @override
  ReceiptScannerState build() {
    _engine = StitchingEngine();
    return ReceiptScannerState();
  }

  void startScanning() {
    _engine.reset();
    state = state.copyWith(
      isScanning: true,
      engineState: EngineState.tracking,
      stitchedHeight: 0,
      errorMessage: null,
    );
  }

  void stopScanning() {
    state = state.copyWith(isScanning: false);
    // Here we would normally trigger the agent submission
  }

  void processCameraImage(CameraImage image) {
    if (!state.isScanning) return;

    // Throttle to roughly 15 FPS to save CPU
    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 60) return;
    _lastProcessTime = now;

    final result = _engine.processFrame(image);
    
    final newState = result['state'] as EngineState;
    final int newHeight = result['totalHeight'] as int? ?? state.stitchedHeight;
    final String? error = result['error'] is String ? result['error'] : null;

    if (state.engineState != newState || state.stitchedHeight != newHeight || error != null) {
      state = state.copyWith(
        engineState: newState,
        stitchedHeight: newHeight,
        errorMessage: error,
      );
    }
  }
}

final receiptScannerControllerProvider = NotifierProvider<ReceiptScannerController, ReceiptScannerState>(() {
  return ReceiptScannerController();
});
