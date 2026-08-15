import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/application/product_comparison_service.dart';
import 'package:lens_wise/core/storage/history_providers.dart';

import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/router/navigation_service.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ProductComparisonScannerState {
  final List<AppImageEntity> capturedImages;
  final bool isAnalyzing;
  final String? errorMessage;
  final ProductComparisonRecord? parsingResult;

  ProductComparisonScannerState({
    this.capturedImages = const [],
    this.isAnalyzing = false,
    this.errorMessage,
    this.parsingResult,
  });

  ProductComparisonScannerState copyWith({
    List<AppImageEntity>? capturedImages,
    bool? isAnalyzing,
    String? errorMessage,
    ProductComparisonRecord? parsingResult,
  }) {
    return ProductComparisonScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
      parsingResult: parsingResult ?? this.parsingResult,
    );
  }
}

class ProductComparisonScannerController extends Notifier<ProductComparisonScannerState> {
  @override
  ProductComparisonScannerState build() {
    return ProductComparisonScannerState();
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

  void setAnalyzing(bool analyzing) {
    state = state.copyWith(isAnalyzing: analyzing);
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error, isAnalyzing: false);
  }

  void reset() {
    state = ProductComparisonScannerState();
  }

  Future<void> analyzeComparison(List<AppImageEntity> images) async {
    if (images.isEmpty) return;
    
    state = state.copyWith(capturedImages: images, isAnalyzing: true, errorMessage: null);
    try {
      final service = ref.read(productComparisonServiceProvider);
      final navService = ref.read(navigationServiceProvider);
      
      final bytesList = images.map((e) => e.bytes).toList();
      final result = await service.analyzeAndSave(bytesList);
      ref.invalidate(comparisonHistoryProvider);
      
      state = state.copyWith(parsingResult: result, isAnalyzing: false);
      
      // Decoupled Navigation: Controller dictates routing upon success
      navService.navigateToProductComparisonRecord(result, images);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false);
      ref.read(notificationProvider.notifier).showError('商品比對失敗：$e');
    }
  }
}

final productComparisonScannerControllerProvider = 
  NotifierProvider<ProductComparisonScannerController, ProductComparisonScannerState>(() {
    return ProductComparisonScannerController();
});
