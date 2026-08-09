import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/engine/stitching_engine.dart';
import 'package:lens_wise/features/receipt_scanner/application/receipt_scanner_service.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_parsing_agent/receipt_parsing_agent.dart';
import 'package:lens_wise/core/storage/history_providers.dart';

class ReceiptScannerState {
  final EngineState engineState;
  final int stitchedHeight;
  final String? errorMessage;
  final bool isScanning;
  final ReceiptParsingResult? parsingResult;

  ReceiptScannerState({
    this.engineState = EngineState.tracking,
    this.stitchedHeight = 0,
    this.errorMessage,
    this.isScanning = false,
    this.parsingResult,
  });

  ReceiptScannerState copyWith({
    EngineState? engineState,
    int? stitchedHeight,
    String? errorMessage,
    bool? isScanning,
    ReceiptParsingResult? parsingResult,
  }) {
    return ReceiptScannerState(
      engineState: engineState ?? this.engineState,
      stitchedHeight: stitchedHeight ?? this.stitchedHeight,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      parsingResult: parsingResult ?? this.parsingResult,
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
  }

  Future<void> analyzeReceipt(Uint8List imageBytes) async {
    state = state.copyWith(errorMessage: null, isAnalyzing: true);
    try {
      final service = ref.read(receiptScannerServiceProvider);
      final result = await service.analyzeAndSave(imageBytes);
      ref.invalidate(receiptHistoryProvider);
      state = state.copyWith(parsingResult: result, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false);
    }
  }

  void processCameraImage(dynamic image) {
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
