import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

String buildTranslatedMenuImageSystemPrompt() {
  return '''
你是一位頂尖的影像修復與平面設計多模態 AI。你的任務是進行「完美的菜單語系轉換」。
你必須**絕對保留**使用者提供之原圖的視覺風格、背景顏色、排版佈局、字體設計與裝飾元素。
你唯一要改變的，是將圖中的文字完美替換為目標語言。
不要改變任何非文字的裝飾、不要增加原圖沒有的元素，純粹進行「保留風格的文字替換」。
確保新生成的文字清晰可見，並完美融入原圖的材質與光影中。
''';
}

String buildTranslatedMenuImageUserPrompt(String targetLanguage, MenuScannerRecord record) {
  final buffer = StringBuffer();
  buffer.writeln('請將這張菜單轉換為 $targetLanguage。');
  buffer.writeln('為了確保翻譯的絕對精準，請**嚴格遵守**以下我為你準備好的「翻譯對照字典」。');
  buffer.writeln('請在原位置使用相近的字體風格填入翻譯後的文字，如果原圖有價格，也請保留在對應位置：\n');
  
  if (record.storeName.isNotEmpty) {
    buffer.writeln('餐廳名稱翻譯: ${record.storeName}');
  }
  
  for (int i = 0; i < record.items.length; i++) {
    final item = record.items[i];
    final original = item.originalName.isNotEmpty ? item.originalName : '項目${i+1}';
    final translated = item.translatedName.isNotEmpty ? item.translatedName : original;
    final priceStr = item.price != null ? ' (價格保留: ${item.price})' : '';
    
    buffer.writeln('- $original -> 替換為: $translated $priceStr');
  }
  
  buffer.writeln('\n請生成一張完整的新菜單圖片。');
  return buffer.toString();
}
