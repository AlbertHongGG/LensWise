import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';

void showProductChat(BuildContext context, ProductRecord record) {
  final systemContextPrompt =
      '''你是一個專業的商品分析助手，根據以下商品資訊回答使用者的問題：
商品名稱: ${record.productName ?? '未知商品'}
原始分析結果:
${record.summary ?? '無'}''';

  showAiChatBottomSheet(
    context,
    contextId: record.id,
    systemContextPrompt: systemContextPrompt,
    initialMessage: '我已經為您分析完這項商品，有什麼想進一步了解的嗎？',
  );
}
