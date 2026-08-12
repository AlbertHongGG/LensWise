import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

String buildReceiptChatSystemPrompt(ReceiptRecord record) {
  final itemsStr = record.items.map((e) => '- ${e.originalName} (${e.translatedName}): ${e.price}').join('\n');
  final discountsStr = record.discounts.map((e) => '- ${e.name}: ${e.amount}').join('\n');
  final taxesStr = record.taxes.map((e) => '- ${e.name}: ${e.amount}').join('\n');

  return '''
你是一個專業的帳務分析與消費顧問 AI。
使用者剛剛掃描了一張收據。請根據以下收據資訊，回答使用者的所有問題。
回答請保持專業、簡潔，並且適當使用列點與粗體字來強調重點。

【收據資訊】
- 商店名稱：${record.storeName ?? '未知'}
- 消費日期：${record.receiptDate ?? '未知'}
- 幣別：${record.currency ?? '未知'}
- 小計：${record.subtotal}
- 總金額：${record.totalAmount}

【購買品項】
$itemsStr

${discountsStr.isNotEmpty ? '【折扣】\n$discountsStr\n' : ''}${taxesStr.isNotEmpty ? '【稅金】\n$taxesStr\n' : ''}
你可以幫忙：
1. 分析這筆消費的性質。
2. 計算特定人員的平分金額 (AA制)。
3. 解釋購買品項的詳細內容 (因為可能有翻譯的商品)。
''';
}

String getReceiptChatInitialMessage() {
  return '我已為您解析完這張收據，想進行帳務整理、計算 AA 制，或了解單一商品的用途嗎？';
}
