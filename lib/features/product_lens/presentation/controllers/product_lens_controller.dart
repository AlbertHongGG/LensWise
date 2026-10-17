import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/product_lens/application/product_lens_service.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_lens_agent.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';

enum ProductLensStatus {
  idle,
  connecting, // 等待首個 Token (TTFT)，使用者停留在 ProcessingPage
  streaming,  // 首個 Token 抵達！ProcessingPage 跳轉至 DetailPage 進行漸進水合
  success,    // 串流結束且已持久化至本地資料庫
  error,      // 發生錯誤
}

class ProductLensState {
  final ProductLensStatus status;
  final ProductLensRecord? result;
  final String? errorMessage;
  final List<AppImageEntity>? appImages;
  final bool isStreamingComplete;

  ProductLensState({
    this.status = ProductLensStatus.idle,
    this.result,
    this.errorMessage,
    this.appImages,
    this.isStreamingComplete = false,
  });

  ProductLensState copyWith({
    ProductLensStatus? status,
    ProductLensRecord? result,
    String? errorMessage,
    List<AppImageEntity>? appImages,
    bool? isStreamingComplete,
  }) {
    return ProductLensState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      appImages: appImages ?? this.appImages,
      isStreamingComplete: isStreamingComplete ?? this.isStreamingComplete,
    );
  }
}

class ProductLensController extends Notifier<ProductLensState> {
  StreamSubscription<StreamingSnapshot<ProductLensRecord>>? _streamSub;

  @override
  ProductLensState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return ProductLensState();
  }

  Future<void> analyzeImage(List<AppImageEntity> appImages) async {
    final aiState = ref.read(aiConfigControllerProvider);
    if (!aiState.isAIAgentEnabled) {
      state = state.copyWith(
        status: ProductLensStatus.error,
        errorMessage: 'AI 輔助未啟用，請至設定開啟。',
      );
      ref.read(notificationProvider.notifier).showError('AI 輔助未啟用，請至設定開啟。');
      return;
    }

    await _streamSub?.cancel();

    state = ProductLensState(
      status: ProductLensStatus.connecting,
      appImages: appImages,
      result: ProductLensRecord.empty(),
      isStreamingComplete: false,
    );

    try {
      final agent = ref.read(productLensAgentProvider);
      final service = ref.read(productLensServiceProvider);
      final bytesList = appImages.map((e) => e.bytes).toList();

      final stream = agent.executeStreamSnapshot(bytesList);

      _streamSub = stream.listen(
        (snapshot) async {
          final isDone = snapshot.isComplete;
          
          state = state.copyWith(
            status: isDone ? ProductLensStatus.success : ProductLensStatus.streaming,
            result: snapshot.data,
            isStreamingComplete: isDone,
          );

          if (isDone) {
            try {
              // 串流完成時，持久化完整記錄至資料庫
              final saved = await service.saveCompletedRecord(snapshot.data, bytesList);
              ref.invalidate(productHistoryProvider);
              state = state.copyWith(result: saved);
            } catch (e) {
              // 記錄持久化失敗不阻斷使用者瀏覽
            }
          }
        },
        onError: (e) {
          state = state.copyWith(
            status: ProductLensStatus.error,
            errorMessage: e.toString(),
          );
          ref.read(notificationProvider.notifier).showError('商品分析失敗：$e');
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductLensStatus.error,
        errorMessage: e.toString(),
      );
      ref.read(notificationProvider.notifier).showError('商品分析失敗：$e');
    }
  }

  void reset() {
    _streamSub?.cancel();
    _streamSub = null;
    if (ref.mounted) {
      state = ProductLensState();
    }
  }
}

final productLensControllerProvider =
    NotifierProvider<ProductLensController, ProductLensState>(
      () => ProductLensController(),
    );
