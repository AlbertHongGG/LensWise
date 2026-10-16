import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_lens_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_scanner_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';

class MockStreamProvider implements AIProvider {
  @override
  final String name = 'mock_stream';

  final List<String> textChunks;

  MockStreamProvider(this.textChunks);

  @override
  Future<GenerateResponse> generate(GenerateRequest request) async {
    return GenerateResponse(text: textChunks.join());
  }

  @override
  Stream<GenerateResponse> generateStream(GenerateRequest request) async* {
    for (final chunk in textChunks) {
      yield GenerateResponse(text: chunk);
    }
  }
}

class MockLogger implements AIAgentLogger {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('Streaming Agents Unit Tests', () {
    test('ProductLensAgent streams progressive snapshots correctly', () async {
      final chunks = [
        '{"status": "success", "data": {"productName": "日清',
        '烏龍麵", "summary": "道地關西風味',
        '", "allergens": ["小麥", "大豆"]}}',
      ];

      final agent = ProductLensAgent(
        AiAgentType.productLens,
        MockStreamProvider(chunks),
        MockLogger(),
        targetLanguage: TargetLanguage.traditionalChinese,
      );

      final snapshots = await agent.executeStreamSnapshot([Uint8List(0)]).toList();
      expect(snapshots.isNotEmpty, isTrue);

      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.productName, '日清烏龍麵');
      expect(last.data.summary, '道地關西風味');
      expect(last.data.allergenAlerts, ['小麥', '大豆']);
    });

    test('MenuScannerAgent streams progressive items correctly', () async {
      final chunks = [
        '{"status": "success", "data": {"storeName": "一蘭拉麵", "items": [',
        '{"originalName": "天然とんこつラーメン", "translatedName": "天然豚骨拉麵", "price": 980.0},',
        '{"originalName": "替玉", "translatedName": "加麵", "price": 210.0}',
        ']}}',
      ];

      final agent = MenuScannerAgent(
        AiAgentType.menuScanner,
        MockStreamProvider(chunks),
        MockLogger(),
        targetLanguage: TargetLanguage.traditionalChinese,
      );

      final snapshots = await agent.executeStreamSnapshot([Uint8List(0)]).toList();
      expect(snapshots.isNotEmpty, isTrue);

      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.storeName, '一蘭拉麵');
      expect(last.data.items.length, 2);
      expect(last.data.items.first.translatedName, '天然豚骨拉麵');
      expect(last.data.items.first.price, 980.0);
    });

    test('ReceiptScannerAgent streams progressive items and totals correctly', () async {
      final chunks = [
        '{"status": "success", "data": {"storeName": "7-Eleven", "receiptDate": "2026-10-16", ',
        '"items": [{"originalName": "おにぎり", "translatedName": "御飯糰", "price": 150.0}],',
        '"subtotal": 150.0, "totalAmount": 165.0}}',
      ];

      final agent = ReceiptScannerAgent(
        AiAgentType.receiptScanner,
        MockStreamProvider(chunks),
        MockLogger(),
        targetLanguage: TargetLanguage.traditionalChinese,
      );

      final snapshots = await agent.executeStreamSnapshot([Uint8List(0)]).toList();
      expect(snapshots.isNotEmpty, isTrue);

      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.storeName, '7-Eleven');
      expect(last.data.items.length, 1);
      expect(last.data.items.first.translatedName, '御飯糰');
      expect(last.data.totalAmount, 165.0);
    });

    test('ProductComparisonAgent streams comparison points correctly', () async {
      final chunks = [
        '{"status": "success", "data": {"title": "日清 vs 明星", "summary": "深度分析", ',
        '"products": [{"originalName": "日清", "translatedName": "日清"}, {"originalName": "明星", "translatedName": "明星"}],',
        '"comparisonPoints": [{"aspect": "麵體", "values": ["粗麵", "細麵"]}]}}',
      ];

      final agent = ProductComparisonAgent(
        AiAgentType.productComparison,
        MockStreamProvider(chunks),
        MockLogger(),
        targetLanguage: TargetLanguage.traditionalChinese,
      );

      final snapshots = await agent.executeStreamSnapshot([Uint8List(0), Uint8List(0)]).toList();
      expect(snapshots.isNotEmpty, isTrue);

      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.title, '日清 vs 明星');
      expect(last.data.products.length, 2);
      expect(last.data.comparisonPoints.length, 1);
      expect(last.data.comparisonPoints.first.aspect, '麵體');
    });
  });
}
