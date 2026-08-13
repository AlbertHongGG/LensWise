import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/translated_menu_image_agent/translated_menu_image_agent.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

class TranslatedMenuImageState {
  final bool isGenerating;
  final String? error;
  final List<Uint8List>? generatedImages;

  TranslatedMenuImageState({
    this.isGenerating = false,
    this.error,
    this.generatedImages,
  });

  TranslatedMenuImageState copyWith({
    bool? isGenerating,
    String? error,
    List<Uint8List>? generatedImages,
  }) {
    return TranslatedMenuImageState(
      isGenerating: isGenerating ?? this.isGenerating,
      // Error should be able to be reset to null, but in dart we usually do it like this:
      // if error is not passed, keep current error. But if we want to clear it, we pass null.
      // We will explicitly handle clearing error in the methods.
    );
  }
  
  TranslatedMenuImageState setGenerating() {
    return TranslatedMenuImageState(
       isGenerating: true,
       error: null,
       generatedImages: generatedImages,
    );
  }
  
  TranslatedMenuImageState setError(String e) {
    return TranslatedMenuImageState(
       isGenerating: false,
       error: e,
       generatedImages: generatedImages,
    );
  }
  
  TranslatedMenuImageState setSuccess(List<Uint8List> images) {
    return TranslatedMenuImageState(
       isGenerating: false,
       error: null,
       generatedImages: images,
    );
  }
}

class TranslatedMenuImageController extends Notifier<TranslatedMenuImageState> {
  @override
  TranslatedMenuImageState build() {
    return TranslatedMenuImageState();
  }

  Future<void> generateTranslatedImage({
    required List<Uint8List> originalImages,
    required String targetLanguage,
    required MenuScannerRecord record,
  }) async {
    if (originalImages.isEmpty) {
      state = state.setError('沒有提供原始菜單圖片。');
      return;
    }

    state = state.setGenerating();

    try {
      final agent = ref.read(translatedMenuImageAgentProvider);
      final request = TranslatedMenuImageRequest(
        images: originalImages,
        targetLanguage: targetLanguage,
        record: record,
      );

      final response = await agent.execute(request);

      if (response.images != null && response.images!.isNotEmpty) {
        state = state.setSuccess(response.images!);
      } else {
        state = state.setError('AI 未能生成翻譯圖片，請稍後再試。');
      }
    } catch (e) {
      state = state.setError(e.toString());
    }
  }

  void clearGeneratedImages() {
    state = TranslatedMenuImageState();
  }
}

final translatedMenuImageControllerProvider = NotifierProvider.autoDispose<TranslatedMenuImageController, TranslatedMenuImageState>(() {
  return TranslatedMenuImageController();
});
