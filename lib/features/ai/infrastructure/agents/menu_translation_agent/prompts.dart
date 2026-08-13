import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

import 'package:lens_wise/core/models/target_language.dart';

String buildMenuTranslationSystemPrompt() {
  return '你是一個專業的圖片翻譯助理。';
}

String buildMenuTranslationUserPrompt(TargetLanguage targetLanguage, MenuScannerRecord record) {
  // 根據使用者的回饋，給予過多限制或強制使用字典反而會導致生成模型在排版和文字替換上出現混亂（夾雜原文、版面跑掉）。
  // 使用最簡單直接的 prompt 反而能激發模型最佳的 end-to-end 圖像翻譯能力。
  return '請幫我生成一張對應的${targetLanguage.displayName}菜單的圖 (把文字替換掉)，請保持原圖的版面與設計風格。';
}
