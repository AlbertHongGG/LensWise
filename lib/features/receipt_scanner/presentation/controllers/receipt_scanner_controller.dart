import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/application/receipt_scanner_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/router/navigation_service.dart';

class ReceiptScannerState {
  final List<Uint8List> capturedImages;
  final String? errorMessage;
  final bool isScanning;
  final ReceiptScannerRecord? receiptRecord;
  final bool isAnalyzing;
  final bool isProcessing;

  ReceiptScannerState({
    this.capturedImages = const [],
    this.errorMessage,
    this.isScanning = false,
    this.receiptRecord,
    this.isAnalyzing = false,
    this.isProcessing = false,
  });

  ReceiptScannerState copyWith({
    List<Uint8List>? capturedImages,
    String? errorMessage,
    bool? isScanning,
    ReceiptScannerRecord? receiptRecord,
    bool? isAnalyzing,
    bool? isProcessing,
  }) {
    return ReceiptScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      receiptRecord: receiptRecord ?? this.receiptRecord,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class ReceiptScannerController extends Notifier<ReceiptScannerState> {
  @override
  ReceiptScannerState build() {
    return ReceiptScannerState();
  }

  void startScanning() {
    state = state.copyWith(
      isScanning: true,
      capturedImages: [],
      errorMessage: null,
    );
  }

  void stopScanning() {
    state = state.copyWith(isScanning: false);
  }
  
  void setProcessing(bool processing) {
    state = state.copyWith(isProcessing: processing);
  }

  void addImage(Uint8List imageBytes) {
    state = state.copyWith(
      capturedImages: [...state.capturedImages, imageBytes],
      errorMessage: null,
    );
  }

  void removeImage(int index) {
    final newList = List<Uint8List>.from(state.capturedImages);
    newList.removeAt(index);
    state = state.copyWith(capturedImages: newList);
  }

  void reset() {
    state = ReceiptScannerState();
  }

  Future<void> analyzeReceipt(List<Uint8List> images) async {
    if (images.isEmpty) return;
    
    state = state.copyWith(capturedImages: images, errorMessage: null, isAnalyzing: true, isProcessing: true);
    try {
      final service = ref.read(receiptScannerServiceProvider);
      final navService = ref.read(navigationServiceProvider);
      
      final record = await service.analyzeAndSave(images);
      ref.invalidate(receiptHistoryProvider);
      
      state = state.copyWith(receiptRecord: record, isAnalyzing: false, isProcessing: false);
      
      if (record != null) {
        // Navigate using the decoupled NavigationService
        navService.navigateToReceiptResult(record, images);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false, isProcessing: false);
    }
  }

  Future<void> updateReceiptScannerRecord(ReceiptScannerRecord updatedRecord) async {
    state = state.copyWith(receiptRecord: updatedRecord);
    try {
      final repository = ref.read(receiptScannerRepositoryProvider);
      await repository.save(updatedRecord.id, updatedRecord);
      ref.invalidate(receiptHistoryProvider);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update record: $e');
    }
  }

  // The engine stream processor is completely removed.
  void processCameraImage(dynamic image) {
    // No-op for manual capture
  }

  Future<List<Uint8List>> getCapturedImages() async {
    if (state.capturedImages.isEmpty) {
      if (state.errorMessage == null) {
        state = state.copyWith(errorMessage: 'No frames captured.');
      }
      return [];
    }
    return state.capturedImages;
  }
}

final receiptScannerControllerProvider = NotifierProvider<ReceiptScannerController, ReceiptScannerState>(() {
  return ReceiptScannerController();
});


