import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_chat_prompts.dart';

void showReceiptChat(BuildContext context, ReceiptScannerRecord record) {
  showAiChatBottomSheet(
    context,
    contextId: 'receipt_${record.id}',
    systemContextPrompt: buildReceiptChatSystemPrompt(record),
    initialMessage: getReceiptChatInitialMessage(),
  );
}
