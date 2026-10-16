import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_scanner_agent.dart';
import 'package:lens_wise/features/receipt_scanner/application/receipt_scanner_service.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

enum ReceiptScannerStatus {
  idle,
  connecting, // 等待首個 Token (TTFT)
  streaming,  // 首個 Token 抵達，進入 ResultPage 漸進展開
  success,    // 結束且持久化
  error,
}

class ReceiptScannerState {
  final List<AppImageEntity> capturedImages;
  final String? errorMessage;
  final bool isScanning;
  final ReceiptScannerRecord? receiptRecord;
  final ReceiptScannerStatus status;
  final bool isStreamingComplete;

  ReceiptScannerState({
    this.capturedImages = const [],
    this.errorMessage,
    this.isScanning = false,
    this.receiptRecord,
    this.status = ReceiptScannerStatus.idle,
    this.isStreamingComplete = false,
  });

  bool get isAnalyzing => status == ReceiptScannerStatus.connecting || status == ReceiptScannerStatus.streaming;
  bool get isProcessing => isAnalyzing;

  ReceiptScannerState copyWith({
    List<AppImageEntity>? capturedImages,
    String? errorMessage,
    bool? isScanning,
    ReceiptScannerRecord? receiptRecord,
    ReceiptScannerStatus? status,
    bool? isStreamingComplete,
  }) {
    return ReceiptScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      receiptRecord: receiptRecord ?? this.receiptRecord,
      status: status ?? this.status,
      isStreamingComplete: isStreamingComplete ?? this.isStreamingComplete,
    );
  }
}

class ReceiptScannerController extends Notifier<ReceiptScannerState> {
  StreamSubscription<StreamingSnapshot<ReceiptScannerRecord>>? _streamSub;

  @override
  ReceiptScannerState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });
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
    _streamSub?.cancel();
    state = ReceiptScannerState();
  }

  Future<void> analyzeReceipt(List<AppImageEntity> images) async {
    if (images.isEmpty) return;

    await _streamSub?.cancel();

    state = state.copyWith(
      capturedImages: images,
      errorMessage: null,
      status: ReceiptScannerStatus.connecting,
      receiptRecord: ReceiptScannerRecord.empty(),
      isStreamingComplete: false,
    );

    try {
      final agent = ref.read(receiptScannerAgentProvider);
      final service = ref.read(receiptScannerServiceProvider);
      final bytesList = images.map((e) => e.bytes).toList();

      final stream = agent.executeStreamSnapshot(bytesList);

      _streamSub = stream.listen(
        (snapshot) async {
          final isDone = snapshot.isComplete;

          state = state.copyWith(
            status: isDone ? ReceiptScannerStatus.success : ReceiptScannerStatus.streaming,
            receiptRecord: snapshot.data,
            isStreamingComplete: isDone,
          );

          if (isDone) {
            try {
              final saved = await service.saveCompletedRecord(snapshot.data, bytesList);
              ref.invalidate(receiptHistoryProvider);
              state = state.copyWith(receiptRecord: saved);
            } catch (_) {}
          }
        },
        onError: (e) {
          state = state.copyWith(
            status: ReceiptScannerStatus.error,
            errorMessage: e.toString(),
          );
          ref.read(notificationProvider.notifier).showError('收據分析失敗：$e');
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ReceiptScannerStatus.error,
        errorMessage: e.toString(),
      );
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
}

final receiptScannerControllerProvider = NotifierProvider<ReceiptScannerController, ReceiptScannerState>(() {
  return ReceiptScannerController();
});
