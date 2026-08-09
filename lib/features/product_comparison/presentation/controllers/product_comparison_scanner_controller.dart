import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/application/comparison_analysis_service.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/core/storage/history_providers.dart';

class ProductComparisonScannerState {
  final List<Uint8List> capturedImages;
  final bool isAnalyzing;
  final String? errorMessage;
  final ProductComparisonResult? parsingResult;

  ProductComparisonScannerState({
    this.capturedImages = const [],
    this.isAnalyzing = false,
    this.errorMessage,
    this.parsingResult,
  });

  ProductComparisonScannerState copyWith({
    List<Uint8List>? capturedImages,
    bool? isAnalyzing,
    String? errorMessage,
    ProductComparisonResult? parsingResult,
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

  void setAnalyzing(bool analyzing) {
    state = state.copyWith(isAnalyzing: analyzing);
  }

  void setError(String error) {
    state = state.copyWith(errorMessage: error, isAnalyzing: false);
  }

  void reset() {
    state = ProductComparisonScannerState();
  }

  Future<void> analyzeComparison(List<Uint8List> images) async {
    if (images.isEmpty) return;
    
    state = state.copyWith(capturedImages: images, isAnalyzing: true, errorMessage: null);
    try {
      final service = ref.read(comparisonAnalysisServiceProvider);
      final result = await service.analyzeAndSave(images);
      ref.invalidate(comparisonHistoryProvider);
      state = state.copyWith(parsingResult: result, isAnalyzing: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false);
    }
  }
}

final productComparisonScannerControllerProvider = 
  NotifierProvider<ProductComparisonScannerController, ProductComparisonScannerState>(() {
    return ProductComparisonScannerController();
});
