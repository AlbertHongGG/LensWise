import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_chat_prompts.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';

void showProductChat(BuildContext context, ProductRecord record) {
  final systemContextPrompt = buildProductChatContextPrompt(record);
  final initialMessage = buildProductChatInitialMessage();

  showAiChatBottomSheet(
    context,
    contextId: record.id,
    systemContextPrompt: systemContextPrompt,
    initialMessage: initialMessage,
  );
}
