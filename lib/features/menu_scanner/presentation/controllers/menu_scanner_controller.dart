import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/router/navigation_service.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/menu_scanner/application/menu_scanner_service.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class MenuScannerState {
  final List<AppImageEntity> capturedImages;
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
    List<AppImageEntity>? capturedImages,
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
    state = MenuScannerState();
  }

  Future<void> analyzeMenu(List<AppImageEntity> images) async {
    if (images.isEmpty) return;

    state = state.copyWith(capturedImages: images, isAnalyzing: true, errorMessage: null);
    try {
      final service = ref.read(menuScannerServiceProvider);
      final navService = ref.read(navigationServiceProvider);

      final bytesList = images.map((e) => e.bytes).toList();
      final result = await service.analyzeAndSave(bytesList);
      
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
