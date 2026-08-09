import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/application/product_analysis_service.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';

enum ProductLensStatus { idle, loading, success, error }

class ProductLensState {
  final ProductLensStatus status;
  final ProductAnalysisResult? result;
  final String? errorMessage;
  final Uint8List? imageBytes;

  ProductLensState({
    this.status = ProductLensStatus.idle,
    this.result,
    this.errorMessage,
    this.imageBytes,
  });

  ProductLensState copyWith({
    ProductLensStatus? status,
    ProductAnalysisResult? result,
    String? errorMessage,
    Uint8List? imageBytes,
  }) {
    return ProductLensState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}

class ProductLensController extends Notifier<ProductLensState> {
  @override
  ProductLensState build() {
    return ProductLensState();
  }

  Future<void> analyzeImage(Uint8List imageBytes) async {
    final aiState = ref.read(aiConfigControllerProvider);
    if (!aiState.isAIAgentEnabled) {
      state = state.copyWith(
        status: ProductLensStatus.error,
        errorMessage: 'AI 輔助未啟用，請至設定開啟。',
      );
      return;
    }

    state = state.copyWith(status: ProductLensStatus.loading, imageBytes: imageBytes);
    try {
      final service = ref.read(productAnalysisServiceProvider);
      final result = await service.analyzeAndSave(imageBytes);
      ref.invalidate(productHistoryProvider);
      
      if (result.status == 'success') {
        state = state.copyWith(
          status: ProductLensStatus.success,
          result: result,
        );
      } else {
        state = state.copyWith(
          status: ProductLensStatus.error,
          errorMessage: result.message ?? '解析失敗，請提供更清晰的圖片。',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ProductLensStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  void reset() {
    state = ProductLensState();
  }
}

final productLensControllerProvider = NotifierProvider<ProductLensController, ProductLensState>(
  () => ProductLensController(),
);
