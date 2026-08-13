import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/translated_menu_image_agent/translated_menu_image_agent.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/application/menu_scanner_service.dart';
import 'package:lens_wise/core/notifications/services/in_app_notification_service.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';

class TranslatedMenuImageState {
  final bool isGenerating;
  final String? error;
  final List<AIImageResponse>? generatedImages;

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
  
  TranslatedMenuImageState setSuccess(List<AIImageResponse> images) {
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

  Future<MenuScannerRecord?> generateTranslatedImage({
    required Uint8List originalImage,
    required String originalImagePath,
    required String targetLanguage,
    required MenuScannerRecord record,
  }) async {
    state = state.setGenerating();

    try {
      final agent = ref.read(translatedMenuImageAgentProvider);
      final request = TranslatedMenuImageRequest(
        images: [originalImage],
        targetLanguage: targetLanguage,
        record: record,
      );

      final response = await agent.execute(request);

      if (response.images != null && response.images!.isNotEmpty) {
        final generatedImage = response.images!.first;
        
        // Save to file system and database
        final menuService = ref.read(menuScannerServiceProvider);
        final updatedRecord = await menuService.saveTranslatedImage(
          record,
          originalImagePath,
          generatedImage,
        );
        
        
        state = state.setSuccess(response.images!);
        final notificationService = ref.read(inAppNotificationServiceProvider);
        notificationService.showSuccess('翻譯完成，您可向左滑動檢視新圖片。', title: '✨ 翻譯成功');
        return updatedRecord;
      } else {
        state = state.setError('AI 未能生成翻譯圖片，請稍後再試。');
        ref.read(inAppNotificationServiceProvider).showError('AI 未能生成翻譯圖片，請稍後再試。');
        return null;
      }
    } catch (e) {
      state = state.setError(e.toString());
      ref.read(inAppNotificationServiceProvider).showError('發生錯誤：$e');
      return null;
    }
  }

  void clearGeneratedImages() {
    state = TranslatedMenuImageState();
  }
}

final translatedMenuImageControllerProvider = NotifierProvider.autoDispose<TranslatedMenuImageController, TranslatedMenuImageState>(() {
  return TranslatedMenuImageController();
});
