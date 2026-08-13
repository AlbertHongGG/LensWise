enum AiAgentType {
  aiChat('AiChat', 'AI 深度探討'),
  menuScanner('MenuScanner', '菜單掃描'),
  menuTranslation('MenuTranslation', '菜單翻譯'),
  productComparison('ProductComparison', '商品比對'),
  productLens('ProductLens', '商品分析'),
  receiptScanner('ReceiptScanner', '發票掃描'),
  systemViewer('SystemViewer', '系統檢視'); // For SystemLogManager itself if needed

  final String id;
  final String displayName;
  const AiAgentType(this.id, this.displayName);

  static AiAgentType? fromId(String id) {
    return AiAgentType.values.where((e) => e.id == id).firstOrNull;
  }
}
