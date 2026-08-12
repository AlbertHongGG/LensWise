import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/presentation/widgets/ai_chat_bottom_sheet.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'package:lens_wise/features/product_comparison/application/prompts/comparison_chat_prompts.dart';

void showComparisonChat(BuildContext context, ComparisonResult result) {
  showAiChatBottomSheet(
    context,
    contextId: 'comparison_chat_${DateTime.now().millisecondsSinceEpoch}',
    systemContextPrompt: buildComparisonChatSystemPrompt(result),
    initialMessage: getComparisonChatInitialMessage(),
  );
}
