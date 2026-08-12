import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

String buildComparisonChatSystemPrompt(ComparisonResult result) {
  final productsContext = result.products.map((p) {
    return '- ${p.translatedName} (${p.originalName})';
  }).join('\n');

  final diffContext = result.comparisonPoints.map((p) {
    return '【${p.aspect}】\n' + p.values.asMap().entries.map((e) => '商品${e.key + 1}: ${e.value}').join('\n');
  }).join('\n\n');
  
  return '''
你是一個專業的商品比較與選購分析顧問 AI。
使用者剛剛比對了多項商品。請根據以下比對報告，客觀且專業地回答使用者的問題。
回答請保持簡潔，並適當使用粗體來強調關鍵差異。

【比較商品清單】
$productsContext

【AI 分析總結】
${result.summary}

【各項規格與特色差異】
$diffContext

你可以幫忙：
1. 針對使用者的特定需求 (例如保濕、CP值)，推薦最適合的商品。
2. 解釋某些規格的差異與實際影響。
3. 提供購買建議與總結。
''';
}

String getComparisonChatInitialMessage() {
  return '我已為您完成商品比對報告，想針對特定差異深入了解，或是需要我幫您針對情境推薦嗎？';
}
