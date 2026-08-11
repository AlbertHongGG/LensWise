import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/application/receipt_scanner_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/engine/panoramic_engine.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/engine/panoramic_stitcher.dart';

class ReceiptScannerState {
  final PanoramicState engineState;
  final int stitchedHeight;
  final String? errorMessage;
  final bool isScanning;
  final ReceiptRecord? receiptRecord;
  final bool isAnalyzing;
  final bool isProcessing; // To replace global ValueNotifier

  ReceiptScannerState({
    this.engineState = PanoramicState.tracking,
    this.stitchedHeight = 0,
    this.errorMessage,
    this.isScanning = false,
    this.receiptRecord,
    this.isAnalyzing = false,
    this.isProcessing = false,
  });

  ReceiptScannerState copyWith({
    PanoramicState? engineState,
    int? stitchedHeight,
    String? errorMessage,
    bool? isScanning,
    ReceiptRecord? receiptRecord,
    bool? isAnalyzing,
    bool? isProcessing,
  }) {
    return ReceiptScannerState(
      engineState: engineState ?? this.engineState,
      stitchedHeight: stitchedHeight ?? this.stitchedHeight,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      receiptRecord: receiptRecord ?? this.receiptRecord,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class ReceiptScannerController extends Notifier<ReceiptScannerState> {
  late final PanoramicEngine _engine;
  DateTime _lastProcessTime = DateTime.now();

  @override
  ReceiptScannerState build() {
    _engine = PanoramicEngine();
    return ReceiptScannerState();
  }

  void startScanning() {
    _engine.reset();
    state = state.copyWith(
      isScanning: true,
      engineState: PanoramicState.tracking,
      stitchedHeight: 0,
      errorMessage: null,
    );
  }

  void stopScanning() {
    state = state.copyWith(isScanning: false);
  }
  
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  Future<void> analyzeReceipt(Uint8List imageBytes) async {
    state = state.copyWith(errorMessage: null, isAnalyzing: true, isProcessing: true);
    try {
      final service = ref.read(receiptScannerServiceProvider);
      final record = await service.analyzeAndSave(imageBytes);
      ref.invalidate(receiptHistoryProvider);
      state = state.copyWith(receiptRecord: record, isAnalyzing: false, isProcessing: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false, isProcessing: false);
    }
  }

  Future<void> updateReceiptRecord(ReceiptRecord updatedRecord) async {
    // 這裡我們不設定 isProcessing，以避免影響全域按鈕，或者視情況顯示區域性 loading
    state = state.copyWith(receiptRecord: updatedRecord);
    try {
      final repository = ref.read(receiptRepositoryProvider);
      await repository.save(updatedRecord.id, updatedRecord);
      ref.invalidate(receiptHistoryProvider);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update record: $e');
    }
  }

  void processCameraImage(dynamic image) {
    if (!state.isScanning) return;

    final now = DateTime.now();
    if (now.difference(_lastProcessTime).inMilliseconds < 100) return; // 10 FPS is plenty for tracking
    _lastProcessTime = now;

    final result = _engine.processFrame(image);
    
    final newState = result['state'] as PanoramicState;
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

  Future<Uint8List?> getStitchedImage() async {
    try {
      if (_engine.bufferedFrames.isEmpty) {
        if (state.errorMessage == null) {
          state = state.copyWith(errorMessage: 'No frames captured. (Is camera format supported?)');
        }
        return null;
      }
      return await PanoramicStitcher.stitchFrames(_engine.bufferedFrames);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Stitch failed: $e');
      return null;
    }
  }
}


final receiptScannerControllerProvider = NotifierProvider<ReceiptScannerController, ReceiptScannerState>(() {
  return ReceiptScannerController();
});

