import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_payload_parser.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

void main() {
  group('ProductComparisonPayloadParser Tests', () {
    test('Parses nested data response correctly with complete products and comparison points', () {
      final json = {
        'status': 'success',
        'data': {
          'title': '青森蘋果汁 vs 富士蘋果汁',
          'summary': '兩款皆為 100% 原汁，青森款酸甜平衡，富士款偏甜。',
          'products': [
            {
              'originalName': '青森りんごジュース',
              'translatedName': '青森蘋果汁',
            },
            {
              'originalName': 'ふじりんごジュース',
              'translatedName': '富士蘋果汁',
            },
          ],
          'comparisonPoints': [
            {
              'aspect': '容量',
              'values': ['1000ml', '900ml'],
            },
            {
              'aspect': '價格',
              'values': ['\$120', '\$105'],
            },
            {
              'aspect': '甜度',
              'values': ['微酸微甜', '純甜濃郁'],
            },
          ],
        }
      };

      final record = ProductComparisonPayloadParser.parseStreamingSnapshot(json);
      expect(record.title, '青森蘋果汁 vs 富士蘋果汁');
      expect(record.summary, contains('兩款皆為 100% 原汁'));
      expect(record.products.length, 2);
      expect(record.products[0].originalName, '青森りんごジュース');
      expect(record.products[0].translatedName, '青森蘋果汁');
      expect(record.products[1].originalName, 'ふじりんごジュース');
      expect(record.products[1].translatedName, '富士蘋果汁');
      expect(record.comparisonPoints.length, 3);
      expect(record.comparisonPoints[0].aspect, '容量');
      expect(record.comparisonPoints[0].values, ['1000ml', '900ml']);
      expect(record.comparisonPoints[1].aspect, '價格');
      expect(record.comparisonPoints[1].values, ['\$120', '\$105']);
      expect(record.comparisonPoints[2].aspect, '甜度');
      expect(record.comparisonPoints[2].values, ['微酸微甜', '純甜濃郁']);
    });

    test('Filters incomplete products during streaming snapshot', () {
      final json = {
        'status': 'success',
        'data': {
          'title': '比對中',
          'summary': '',
          'products': [
            {
              'originalName': 'Product A',
              'translatedName': '商品 A',
            },
            {
              'originalName': 'Product B',
              // translatedName missing or empty during streaming
              'translatedName': '',
            },
            {
              // originalName missing
              'originalName': '',
              'translatedName': '商品 C',
            },
          ],
          'comparisonPoints': [],
        }
      };

      final record = ProductComparisonPayloadParser.parseStreamingSnapshot(json);
      expect(record.products.length, 1);
      expect(record.products[0].originalName, 'Product A');
      expect(record.products[0].translatedName, '商品 A');
    });

    test('Filters incomplete comparison points to prevent broken matrix grid', () {
      final json = {
        'status': 'success',
        'data': {
          'title': '比對結果',
          'summary': '',
          'products': [
            {'originalName': 'A', 'translatedName': '甲'},
            {'originalName': 'B', 'translatedName': '乙'},
          ],
          'comparisonPoints': [
            {
              'aspect': '產地',
              'values': ['日本', '台灣'],
            },
            {
              'aspect': '熱量',
              // Still streaming second value
              'values': ['150kcal', ''],
            },
            {
              'aspect': '',
              'values': ['10g', '20g'],
            },
            {
              'aspect': '空維度',
              'values': [],
            },
          ],
        }
      };

      final record = ProductComparisonPayloadParser.parseStreamingSnapshot(json);
      expect(record.comparisonPoints.length, 1);
      expect(record.comparisonPoints[0].aspect, '產地');
      expect(record.comparisonPoints[0].values, ['日本', '台灣']);
    });

    test('Supports flat root json without data wrapper', () {
      final json = {
        'title': '平面結構比對',
        'summary': '總結',
        'products': [
          {'originalName': 'P1', 'translatedName': '商品1'},
        ],
        'comparisonPoints': [
          {'aspect': '特色', 'values': ['高CP值']},
        ],
      };

      final record = ProductComparisonPayloadParser.parseStreamingSnapshot(json);
      expect(record.title, '平面結構比對');
      expect(record.summary, '總結');
      expect(record.products.length, 1);
      expect(record.comparisonPoints.length, 1);
    });

    test('Simulate incremental streaming chunks through JsonStreamPipeline', () async {
      final fullJson = jsonEncode({
        'status': 'success',
        'data': {
          'title': '漸進式串流測試',
          'summary': '這是測試摘要',
          'products': [
            {'originalName': 'Tea A', 'translatedName': '綠茶'},
            {'originalName': 'Tea B', 'translatedName': '紅茶'},
          ],
          'comparisonPoints': [
            {'aspect': '發酵度', 'values': ['未發酵', '全發酵']},
            {'aspect': '風味', 'values': ['清香', '醇厚']},
          ],
        }
      });

      Stream<String> chunkStream() async* {
        for (int i = 0; i < fullJson.length; i += 16) {
          final end = (i + 16 < fullJson.length) ? i + 16 : fullJson.length;
          yield fullJson.substring(i, end);
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }

      final pipeline = JsonStreamPipeline.bind<ProductComparisonRecord>(
        rawStream: chunkStream(),
        mapper: ProductComparisonPayloadParser.parseStreamingSnapshot,
        initialData: ProductComparisonRecord.empty(),
        throttleDuration: const Duration(milliseconds: 20),
      );

      final snapshots = <ProductComparisonRecord>[];
      await for (final snapshot in pipeline) {
        snapshots.add(snapshot.data);
      }

      expect(snapshots.isNotEmpty, isTrue);
      final finalData = snapshots.last;
      expect(finalData.title, '漸進式串流測試');
      expect(finalData.summary, '這是測試摘要');
      expect(finalData.products.length, 2);
      expect(finalData.comparisonPoints.length, 2);
    });

    test('Simulate optimized topology streaming: products and comparisonPoints arrive before structured markdown summary', () async {
      // In optimized topology: title -> products -> comparisonPoints -> summary
      final structuredMarkdown = '## 核心結論\n這是一場 **平價便利** 與 **名店職人風味** 的本質對決。\n\n## 選購指南：誰該買哪款？\n- **商品 0**：適合追求極致性價比者。\n- **商品 1**：適合追求道地香氣與口感者。\n\n## 關鍵取捨與避坑\n- 商品 1 單價較高且鈉含量偏高，請酌量飲用高湯。';

      final intermediateJson = {
        'status': 'success',
        'data': {
          'title': '日清泡麵頂上對決',
          'products': [
            {'originalName': 'どん兵衛 きつねうどん', 'translatedName': '日清兵衛豆皮烏龍麵'},
            {'originalName': 'どん兵衛 鴨だしそば', 'translatedName': '日清兵衛鴨肉高湯蕎麥麵'},
          ],
          'comparisonPoints': [
            {'aspect': '麵體與沖泡時間', 'values': ['粗烏龍麵 (5分鐘)', '細蕎麥麵 (3分鐘)']},
          ],
          // summary not arrived yet!
        }
      };

      final intermediateRecord = ProductComparisonPayloadParser.parseStreamingSnapshot(intermediateJson);
      expect(intermediateRecord.title, '日清泡麵頂上對決');
      expect(intermediateRecord.products.length, 2);
      expect(intermediateRecord.comparisonPoints.length, 1);
      expect(intermediateRecord.summary, ''); // Summary gracefully defaults to empty string for skeleton loader

      final completedJson = {
        'status': 'success',
        'data': {
          'title': '日清泡麵頂上對決',
          'products': [
            {'originalName': 'どん兵衛 きつねうどん', 'translatedName': '日清兵衛豆皮烏龍麵'},
            {'originalName': 'どん兵衛 鴨だしそば', 'translatedName': '日清兵衛鴨肉高湯蕎麥麵'},
          ],
          'comparisonPoints': [
            {'aspect': '麵體與沖泡時間', 'values': ['粗烏龍麵 (5分鐘)', '細蕎麥麵 (3分鐘)']},
          ],
          'summary': structuredMarkdown,
        }
      };

      final completedRecord = ProductComparisonPayloadParser.parseStreamingSnapshot(completedJson);
      expect(completedRecord.title, '日清泡麵頂上對決');
      expect(completedRecord.products.length, 2);
      expect(completedRecord.comparisonPoints.length, 1);
      expect(completedRecord.summary, contains('## 核心結論'));
      expect(completedRecord.summary, contains('**平價便利**'));
      expect(completedRecord.summary, contains('## 選購指南：誰該買哪款？'));
      expect(completedRecord.summary, contains('## 關鍵取捨與避坑'));
    });
  });
}
