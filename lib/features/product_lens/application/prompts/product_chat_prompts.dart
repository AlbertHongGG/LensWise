import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

String buildProductChatContextPrompt(ProductRecord record) {
  return '''你是一個專業的商品分析助手，根據以下商品資訊回答使用者的問題：
商品名稱: ${record.productName ?? '未知商品'}
原始分析結果:
${record.summary ?? '無'}''';
}

String buildProductChatInitialMessage() {
  return '我已經為您分析完這項商品，有什麼想進一步了解的嗎？';
}
