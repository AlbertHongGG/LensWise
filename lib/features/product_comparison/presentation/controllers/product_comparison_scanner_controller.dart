import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductComparisonScannerState {
  final List<Uint8List> capturedImages;
  final bool isAnalyzing;
  final String? errorMessage;

  ProductComparisonScannerState({
    this.capturedImages = const [],
    this.isAnalyzing = false,
    this.errorMessage,
  });

  ProductComparisonScannerState copyWith({
    List<Uint8List>? capturedImages,
    bool? isAnalyzing,
    String? errorMessage,
  }) {
    return ProductComparisonScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
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
}

final productComparisonScannerControllerProvider = 
  NotifierProvider<ProductComparisonScannerController, ProductComparisonScannerState>(() {
    return ProductComparisonScannerController();
});
