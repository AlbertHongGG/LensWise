import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_lens/application/product_lens_service.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';

enum ProductLensStatus { idle, loading, success, error }

class ProductLensState {
  final ProductLensStatus status;
  final ProductLensRecord? result;
  final String? errorMessage;
  final List<Uint8List>? imageBytesList;

  ProductLensState({
    this.status = ProductLensStatus.idle,
    this.result,
    this.errorMessage,
    this.imageBytesList,
  });

  ProductLensState copyWith({
    ProductLensStatus? status,
    ProductLensRecord? result,
    String? errorMessage,
    List<Uint8List>? imageBytesList,
  }) {
    return ProductLensState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      imageBytesList: imageBytesList ?? this.imageBytesList,
    );
  }
}

class ProductLensController extends Notifier<ProductLensState> {
  @override
  ProductLensState build() {
    return ProductLensState();
  }

  Future<void> analyzeImage(List<Uint8List> imageBytesList) async {
    final aiState = ref.read(aiConfigControllerProvider);
    if (!aiState.isAIAgentEnabled) {
      state = state.copyWith(
        status: ProductLensStatus.error,
        errorMessage: 'AI 輔助未啟用，請至設定開啟。',
      );
      return;
    }

    state = state.copyWith(
      status: ProductLensStatus.loading,
      imageBytesList: imageBytesList,
    );
    try {
      final service = ref.read(productLensServiceProvider);
      final result = await service.analyzeAndSave(imageBytesList);
      ref.invalidate(productHistoryProvider);

      state = state.copyWith(
        status: ProductLensStatus.success,
        result: result,
      );
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

final productLensControllerProvider =
    NotifierProvider<ProductLensController, ProductLensState>(
      () => ProductLensController(),
    );
