import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/application/receipt_scanner_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/router/navigation_service.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ReceiptScannerState {
  final List<AppImageEntity> capturedImages;
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
    List<AppImageEntity>? capturedImages,
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

  void addImage(AppImageEntity image) {
    state = state.copyWith(
      capturedImages: [...state.capturedImages, image],
      errorMessage: null,
    );
  }

  void removeImage(int index) {
    final newList = List<AppImageEntity>.from(state.capturedImages);
    newList.removeAt(index);
    state = state.copyWith(capturedImages: newList);
  }

  void reset() {
    state = ReceiptScannerState();
  }

  Future<void> analyzeReceipt(List<AppImageEntity> images) async {
    if (images.isEmpty) return;
    
    state = state.copyWith(capturedImages: images, errorMessage: null, isAnalyzing: true, isProcessing: true);
    try {
      final service = ref.read(receiptScannerServiceProvider);
      final navService = ref.read(navigationServiceProvider);
      
      final bytesList = images.map((e) => e.bytes).toList();
      final record = await service.analyzeAndSave(bytesList);
      ref.invalidate(receiptHistoryProvider);
      
      state = state.copyWith(receiptRecord: record, isAnalyzing: false, isProcessing: false);
      
      if (record != null) {
        // Navigate using the decoupled NavigationService
        // Assuming NavigationService uses AppImageEntity or Uint8List?
        // We will pass AppImageEntity so UI can use it.
        navService.navigateToReceiptResult(record, images);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false, isProcessing: false);
      ref.read(notificationProvider.notifier).showError('收據分析失敗：$e');
    }
  }

  Future<void> updateReceiptScannerRecord(ReceiptScannerRecord updatedRecord) async {
    state = state.copyWith(receiptRecord: updatedRecord);
    try {
      final repository = ref.read(receiptScannerRepositoryProvider);
      await repository.save(updatedRecord.id, updatedRecord);
      ref.invalidate(receiptHistoryProvider);
      ref.read(notificationProvider.notifier).showSuccess('紀錄已更新');
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update record: $e');
      ref.read(notificationProvider.notifier).showError('更新失敗：$e');
    }
  }

  // The engine stream processor is completely removed.
  void processCameraImage(dynamic image) {
    // No-op for manual capture
  }

  Future<List<AppImageEntity>> getCapturedImages() async {
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


