import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_chat_prompts.dart';

void showMenuChat(BuildContext context, MenuScannerRecord record) {
  showAiChatBottomSheet(
    context,
    contextId: 'menu_${record.id}',
    systemContextPrompt: buildMenuChatSystemPrompt(record),
    initialMessage: getMenuChatInitialMessage(),
  );
}
