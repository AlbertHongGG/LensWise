import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

String buildProductChatContextPrompt(ProductRecord record) {
  final ingredientsText = record.ingredients.isNotEmpty 
      ? '成分: ${record.ingredients.join(', ')}\n' 
      : '';
  final allergenText = record.allergenAlerts.isNotEmpty 
      ? '過敏原警告: ${record.allergenAlerts.join(', ')}\n' 
      : '';

  return '''
你是一個具備深厚專業知識的頂級商品分析顧問 AI。
使用者剛剛掃描並分析了一項商品，以下是該商品的基礎報告。

【重要指令】
當使用者針對商品成分、功效或特性提問時，絕對不要只是重複報告中的字句。
你必須運用你龐大的世界知識庫，為使用者進行「深度科普與延伸解析」。
例如：如果使用者詢問某種成分，你應該解釋該成分的化學性質、實際功效、業界常見用途，甚至潛在的副作用。
請扮演真正的領域專家，提供高維度的專業見解。
回答請保持結構化，並適當使用粗體來強調關鍵知識點。

【商品資訊】
商品名稱: ${record.productName}
品牌: ${record.brand.isNotEmpty ? record.brand : '未知'}
產地: ${record.origin.isNotEmpty ? record.origin : '未知'}

【核心成分與過敏原】
$ingredientsText$allergenText
【AI 基礎分析總結】
${record.summary}
''';
}

String buildProductChatInitialMessage() {
  return '我已經為您分析完這項商品，有什麼想進一步了解的嗎？';
}
