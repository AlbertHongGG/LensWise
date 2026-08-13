import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_chat_prompts.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';

void showProductChat(BuildContext context, ProductLensRecord record) {
  final systemContextPrompt = buildProductChatContextPrompt(record);
  final initialMessage = buildProductChatInitialMessage();

  showAiChatBottomSheet(
    context,
    contextId: record.id,
    systemContextPrompt: systemContextPrompt,
    initialMessage: initialMessage,
  );
}
