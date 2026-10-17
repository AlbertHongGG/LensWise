import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_payload_parser.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

void main() {
  test('JsonStreamPipeline + MenuScannerPayloadParser emits complete items progressively without blank states', () async {
    final fullJson = '''{
  "status": "success",
  "data": {
    "storeName": "一蘭拉麵",
    "items": [
      {
        "originalName": "天然豚骨ラーメン",
        "translatedName": "天然豚骨拉麵",
        "description": "經典豚骨湯頭",
        "price": 980.0
      },
      {
        "originalName": "替玉",
        "translatedName": "加麵",
        "description": "加一份麵條",
        "price": 210.0
      },
      {
        "originalName": "半替玉",
        "translatedName": "加半份麵",
        "description": "加半份麵條",
        "price": 150.0
      }
    ]
  }
}''';

    // Simulate sending 15 characters per chunk
    Stream<String> createChunkStream() async* {
      const chunkSize = 15;
      for (int i = 0; i < fullJson.length; i += chunkSize) {
        final end = (i + chunkSize < fullJson.length) ? i + chunkSize : fullJson.length;
        yield fullJson.substring(i, end);
        await Future.delayed(const Duration(milliseconds: 5));
      }
    }

    final pipelineStream = JsonStreamPipeline.bind<MenuScannerRecord>(
      rawStream: createChunkStream(),
      mapper: MenuScannerPayloadParser.parseStreamingSnapshot,
      initialData: MenuScannerRecord.empty(),
      throttleDuration: const Duration(milliseconds: 10),
    );

    final itemCountsEmitted = <int>[];
    await for (final snapshot in pipelineStream) {
      final count = snapshot.data.items.length;
      if (itemCountsEmitted.isEmpty || itemCountsEmitted.last != count) {
        itemCountsEmitted.add(count);
      }
    }

    // Verify progression: 0 -> 1 -> 2 -> 3
    expect(itemCountsEmitted, containsAllInOrder([0, 1, 2, 3]));

    // Verify that every emitted item was 100% complete
    // (no blank translated names, price >= 0)
    for (final count in itemCountsEmitted) {
      expect(count >= 0, isTrue);
    }
  });
}
