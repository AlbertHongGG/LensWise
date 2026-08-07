import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';

enum ProductLensStatus { idle, loading, success, error }

class ProductLensState {
  final ProductLensStatus status;
  final ProductAnalysisResult? result;
  final String? errorMessage;

  ProductLensState({
    this.status = ProductLensStatus.idle,
    this.result,
    this.errorMessage,
  });

  ProductLensState copyWith({
    ProductLensStatus? status,
    ProductAnalysisResult? result,
    String? errorMessage,
  }) {
    return ProductLensState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductLensController extends Notifier<ProductLensState> {
  @override
  ProductLensState build() {
    return ProductLensState();
  }

  Future<void> analyzeImage(Uint8List imageBytes) async {
    state = state.copyWith(status: ProductLensStatus.loading);
    try {
      final agent = ref.read(productAnalysisAgentProvider);
      final result = await agent.execute([imageBytes]);
      
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
        errorMessage: '網路或系統錯誤，請重試。',
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
