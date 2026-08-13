import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_parsing_agent/receipt_chat_prompts.dart';

void showReceiptChat(BuildContext context, ReceiptRecord record) {
  showAiChatBottomSheet(
    context,
    contextId: 'receipt_${record.id}',
    systemContextPrompt: buildReceiptChatSystemPrompt(record),
    initialMessage: getReceiptChatInitialMessage(),
  );
}
