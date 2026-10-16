import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';

class TestProduct {
  final String name;
  final String summary;
  final List<String> allergens;

  const TestProduct({
    this.name = '',
    this.summary = '',
    this.allergens = const [],
  });

  factory TestProduct.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return TestProduct(
      name: data['productName'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      allergens: (data['allergens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

void main() {
  group('JsonStreamPipeline', () {
    test('extractJsonSubstring correctly strips markdown or leading text', () {
      expect(
        JsonStreamPipeline.extractJsonSubstring('```json\n{"key": "value"}'),
        '{"key": "value"}',
      );
      expect(
        JsonStreamPipeline.extractJsonSubstring('Here is the result:\n{"a": 1}'),
        '{"a": 1}',
      );
      expect(
        JsonStreamPipeline.extractJsonSubstring('{"direct": true}'),
        '{"direct": true}',
      );
    });

    test('reairs partial JSON chunks and emits progressive snapshots', () async {
      final chunks = [
        '```json\n{\n  "data": {\n    "productName": "日清',
        '烏龍麵",\n    "summary": "關西風味',
        '高湯泡麵",\n    "allergens": ["小麥',
        '", "大豆"]\n  }\n}',
      ];

      final rawStream = Stream.fromIterable(chunks);

      final snapshots = await JsonStreamPipeline.bind<TestProduct>(
        rawStream: rawStream,
        mapper: (json) => TestProduct.fromJson(json),
        initialData: const TestProduct(),
        throttleDuration: Duration.zero, // Zero throttle for deterministic test
      ).toList();

      expect(snapshots.isNotEmpty, isTrue);

      // Verify that the first snapshot captured the partial product name
      final first = snapshots.first;
      expect(first.isComplete, isFalse);
      expect(first.data.name, contains('日清'));

      // Verify that the final snapshot has all data and isComplete == true
      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.name, '日清烏龍麵');
      expect(last.data.summary, '關西風味高湯泡麵');
      expect(last.data.allergens, ['小麥', '大豆']);
    });

    test('gracefully handles truncated stream and emits final snapshot', () async {
      final chunks = [
        '{"data": {"productName": "未完成商品", "summary": "只有一半',
      ];

      final rawStream = Stream.fromIterable(chunks);

      final snapshots = await JsonStreamPipeline.bind<TestProduct>(
        rawStream: rawStream,
        mapper: (json) => TestProduct.fromJson(json),
        initialData: const TestProduct(),
        throttleDuration: Duration.zero,
      ).toList();

      expect(snapshots.isNotEmpty, isTrue);
      final last = snapshots.last;
      expect(last.isComplete, isTrue);
      expect(last.data.name, '未完成商品');
      expect(last.data.summary, '只有一半');
    });
  });
}
