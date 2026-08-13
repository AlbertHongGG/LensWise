import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_translation_agent/menu_translation_agent.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/application/menu_scanner_service.dart';
import 'package:lens_wise/core/notifications/services/in_app_notification_service.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/core/models/target_language.dart';

class MenuTranslationState {
  final bool isGenerating;
  final String? error;
  final List<AIImageResponse>? generatedImages;

  MenuTranslationState({
    this.isGenerating = false,
    this.error,
    this.generatedImages,
  });

  MenuTranslationState copyWith({
    bool? isGenerating,
    String? error,
    List<Uint8List>? generatedImages,
  }) {
    return MenuTranslationState(
      isGenerating: isGenerating ?? this.isGenerating,
      // Error should be able to be reset to null, but in dart we usually do it like this:
      // if error is not passed, keep current error. But if we want to clear it, we pass null.
      // We will explicitly handle clearing error in the methods.
    );
  }
  
  MenuTranslationState setGenerating() {
    return MenuTranslationState(
       isGenerating: true,
       error: null,
       generatedImages: generatedImages,
    );
  }
  
  MenuTranslationState setError(String e) {
    return MenuTranslationState(
       isGenerating: false,
       error: e,
       generatedImages: generatedImages,
    );
  }
  
  MenuTranslationState setSuccess(List<AIImageResponse> images) {
    return MenuTranslationState(
      isGenerating: false,
       error: null,
       generatedImages: images,
    );
  }
}

class MenuTranslationController extends Notifier<MenuTranslationState> {
  @override
  MenuTranslationState build() {
    return MenuTranslationState();
  }

  Future<MenuScannerRecord?> generateTranslatedImage({
    required Uint8List originalImage,
    required String originalImagePath,
    required TargetLanguage targetLanguage,
    required MenuScannerRecord record,
  }) async {
    state = state.setGenerating();

    try {
      final agent = ref.read(menuTranslationAgentProvider);
      final request = MenuTranslationRequest(
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
    state = MenuTranslationState();
  }
}

final menuTranslationControllerProvider = NotifierProvider.autoDispose<MenuTranslationController, MenuTranslationState>(() {
  return MenuTranslationController();
});
