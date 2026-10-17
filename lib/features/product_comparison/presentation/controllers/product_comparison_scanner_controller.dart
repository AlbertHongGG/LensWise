import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/features/product_comparison/application/product_comparison_service.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';

enum ProductComparisonStatus {
  idle,
  connecting, // 等待首個 Token (TTFT)
  streaming,  // 首個 Token 抵達，進入 ResultPage 漸進展開
  success,    // 結束且持久化
  error,
}

class ProductComparisonScannerState {
  final List<AppImageEntity> capturedImages;
  final ProductComparisonStatus status;
  final String? errorMessage;
  final ProductComparisonRecord? parsingResult;
  final bool isStreamingComplete;

  ProductComparisonScannerState({
    this.capturedImages = const [],
    this.status = ProductComparisonStatus.idle,
    this.errorMessage,
    this.parsingResult,
    this.isStreamingComplete = false,
  });

  bool get isAnalyzing => status == ProductComparisonStatus.connecting || status == ProductComparisonStatus.streaming;

  ProductComparisonScannerState copyWith({
    List<AppImageEntity>? capturedImages,
    ProductComparisonStatus? status,
    String? errorMessage,
    ProductComparisonRecord? parsingResult,
    bool? isStreamingComplete,
  }) {
    return ProductComparisonScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      parsingResult: parsingResult ?? this.parsingResult,
      isStreamingComplete: isStreamingComplete ?? this.isStreamingComplete,
    );
  }
}

class ProductComparisonScannerController extends Notifier<ProductComparisonScannerState> {
  StreamSubscription<StreamingSnapshot<ProductComparisonRecord>>? _streamSub;

  @override
  ProductComparisonScannerState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return ProductComparisonScannerState();
  }

  void reset() {
    _streamSub?.cancel();
    _streamSub = null;
    if (ref.mounted) {
      state = ProductComparisonScannerState();
    }
  }

  Future<void> analyzeComparison(List<AppImageEntity> images) async {
    if (images.isEmpty) return;

    final aiState = ref.read(aiConfigControllerProvider);
    if (!aiState.isAIAgentEnabled) {
      state = state.copyWith(
        status: ProductComparisonStatus.error,
        errorMessage: 'AI 輔助未啟用，請至設定開啟。',
      );
      ref.read(notificationProvider.notifier).showError('AI 輔助未啟用，請至設定開啟。');
      return;
    }

    await _streamSub?.cancel();

    state = state.copyWith(
      capturedImages: images,
      status: ProductComparisonStatus.connecting,
      errorMessage: null,
      parsingResult: ProductComparisonRecord.empty(),
      isStreamingComplete: false,
    );

    try {
      final agent = ref.read(productComparisonAgentProvider);
      final service = ref.read(productComparisonServiceProvider);
      final bytesList = images.map((e) => e.bytes).toList();

      final stream = agent.executeStreamSnapshot(bytesList);

      _streamSub = stream.listen(
        (snapshot) async {
          final isDone = snapshot.isComplete;

          state = state.copyWith(
            status: isDone ? ProductComparisonStatus.success : ProductComparisonStatus.streaming,
            parsingResult: snapshot.data,
            isStreamingComplete: isDone,
          );

          if (isDone) {
            try {
              final saved = await service.saveCompletedRecord(snapshot.data, bytesList);
              ref.invalidate(comparisonHistoryProvider);
              state = state.copyWith(parsingResult: saved);
            } catch (_) {}
          }
        },
        onError: (e) {
          state = state.copyWith(
            status: ProductComparisonStatus.error,
            errorMessage: e.toString(),
          );
          ref.read(notificationProvider.notifier).showError('商品比對失敗：$e');
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductComparisonStatus.error,
        errorMessage: e.toString(),
      );
      ref.read(notificationProvider.notifier).showError('商品比對失敗：$e');
    }
  }
}

final productComparisonScannerControllerProvider = 
  NotifierProvider<ProductComparisonScannerController, ProductComparisonScannerState>(() {
    return ProductComparisonScannerController();
});
