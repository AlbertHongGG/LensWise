import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/router/navigation_service.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/menu_scanner/application/menu_scanner_service.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

class MenuScannerState {
  final List<Uint8List> capturedImages;
  final bool isAnalyzing;
  final String? errorMessage;
  final MenuScannerRecord? parsingResult;

  MenuScannerState({
    this.capturedImages = const [],
    this.isAnalyzing = false,
    this.errorMessage,
    this.parsingResult,
  });

  MenuScannerState copyWith({
    List<Uint8List>? capturedImages,
    bool? isAnalyzing,
    String? errorMessage,
    MenuScannerRecord? parsingResult,
  }) {
    return MenuScannerState(
      capturedImages: capturedImages ?? this.capturedImages,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage ?? this.errorMessage,
      parsingResult: parsingResult ?? this.parsingResult,
    );
  }
}

class MenuScannerController extends Notifier<MenuScannerState> {
  @override
  MenuScannerState build() {
    return MenuScannerState();
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
    state = MenuScannerState();
  }

  Future<void> analyzeMenu(List<Uint8List> images) async {
    if (images.isEmpty) return;

    state = state.copyWith(capturedImages: images, isAnalyzing: true, errorMessage: null);
    try {
      final service = ref.read(menuScannerServiceProvider);
      final navService = ref.read(navigationServiceProvider);

      final result = await service.analyzeAndSave(images);
      
      // Invalidate the history provider to trigger a rebuild
      ref.invalidate(menuHistoryProvider);

      state = state.copyWith(parsingResult: result, isAnalyzing: false);

      // Decoupled Navigation
      navService.navigateToMenuRecord(result, images);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isAnalyzing: false);
    }
  }
}

final menuScannerControllerProvider = NotifierProvider<MenuScannerController, MenuScannerState>(() {
  return MenuScannerController();
});
