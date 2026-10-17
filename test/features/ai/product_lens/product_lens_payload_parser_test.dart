import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_lens_agent/product_lens_payload_parser.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

void main() {
  group('ProductLensPayloadParser Tests', () {
    test('Parses nested data response correctly', () {
      final json = {
        'status': 'success',
        'data': {
          'productName': '天然綠茶茶包',
          'originalName': 'Green Tea Bags',
          'brand': '伊藤園',
          'origin': '日本靜岡',
          'summary': '採用 100% 靜岡產綠茶葉，口感甘甜回甘，無人工添加物。',
          'ingredients': ['綠茶', '抹茶'],
          'allergens': ['無'],
          'dietaryFlags': ['純素', '無麩質'],
          'recommendedFor': ['上班族', '喜愛無糖茶飲者'],
          'notRecommendedFor': ['對咖啡因敏感者'],
        }
      };

      final record = ProductLensPayloadParser.parseStreamingSnapshot(json);
      expect(record.productName, '天然綠茶茶包');
      expect(record.originalName, 'Green Tea Bags');
      expect(record.brand, '伊藤園');
      expect(record.origin, '日本靜岡');
      expect(record.summary, contains('靜岡產綠茶葉'));
      expect(record.ingredients, ['綠茶', '抹茶']);
      expect(record.allergenAlerts, ['無']);
      expect(record.dietaryFlags, ['純素', '無麩質']);
      expect(record.whenRecommended, ['上班族', '喜愛無糖茶飲者']);
      expect(record.whenNotRecommended, ['對咖啡因敏感者']);
    });

    test('Safely filters empty or whitespace strings in list fields', () {
      final json = {
        'status': 'success',
        'data': {
          'productName': '無糖豆漿',
          'ingredients': ['水', '  ', '非基改黃豆', ''],
          'allergens': ['大豆', null, ' '],
        }
      };

      final record = ProductLensPayloadParser.parseStreamingSnapshot(json);
      expect(record.productName, '無糖豆漿');
      expect(record.ingredients, ['水', '非基改黃豆']);
      expect(record.allergenAlerts, ['大豆']);
    });

    test('Handles partial / incomplete json safely without throwing TypeError', () {
      final json = {
        'status': 'success',
        'data': {
          'productName': '餅乾',
          // ingredients is partial or wrong type during streaming repair
          'ingredients': '小麥粉',
        }
      };

      final record = ProductLensPayloadParser.parseStreamingSnapshot(json);
      expect(record.productName, '餅乾');
      expect(record.ingredients, isEmpty);
    });

    test('Simulate incremental streaming chunks through JsonStreamPipeline', () async {
      final fullJson = jsonEncode({
        'status': 'success',
        'data': {
          'productName': '青森蘋果汁',
          'originalName': 'Aomori Apple Juice',
          'brand': 'JAアオレン',
          'origin': '日本青森',
          'summary': '使用完熟青森蘋果冷壓榨汁，香氣濃郁甜酸適中。',
          'ingredients': ['蘋果原汁', '維生素C'],
          'allergens': ['蘋果'],
          'dietaryFlags': ['100% 原汁', '無防腐劑'],
          'recommendedFor': ['全家老少', '果汁愛好者'],
          'notRecommendedFor': [],
        }
      });

      // Split into 16-char slices
      Stream<String> chunkStream() async* {
        for (int i = 0; i < fullJson.length; i += 16) {
          final end = (i + 16 < fullJson.length) ? i + 16 : fullJson.length;
          yield fullJson.substring(i, end);
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }

      final pipeline = JsonStreamPipeline.bind<ProductLensRecord>(
        rawStream: chunkStream(),
        mapper: ProductLensPayloadParser.parseStreamingSnapshot,
        initialData: ProductLensRecord.empty(),
        throttleDuration: const Duration(milliseconds: 20),
      );

      final snapshots = <ProductLensRecord>[];
      await for (final snapshot in pipeline) {
        snapshots.add(snapshot.data);
      }

      expect(snapshots.isNotEmpty, isTrue);
      expect(snapshots.last.productName, '青森蘋果汁');
      expect(snapshots.last.ingredients.length, 2);
    });
  });
}
