import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/menu_scanner_agent/menu_scanner_payload_parser.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

void main() {
  test('Feed log_051537 response text chunk by chunk into JsonStreamPipeline', () async {
    final file = File(r'C:\Users\JasonHong\.gemini\antigravity\brain\1fa6bb8b-ff10-4a3d-b32e-a8b016a2b5ea\scratch\log_051537.json');
    final bytes = file.readAsBytesSync();
    String content;
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
      final sub = bytes.sublist(2);
      final uint16 = sub.buffer.asUint16List();
      content = String.fromCharCodes(uint16);
    } else {
      content = utf8.decode(bytes);
    }
    final logMap = jsonDecode(content) as Map<String, dynamic>;
    final respMap = logMap['response'] as Map<String, dynamic>;
    final fullText = respMap['text'] as String;

    print('Full text length: ${fullText.length}');

    // Simulate streaming by splitting fullText into 20-character chunks
    Stream<String> createChunkStream() async* {
      for (int i = 0; i < fullText.length; i += 20) {
        final end = (i + 20 < fullText.length) ? i + 20 : fullText.length;
        yield fullText.substring(i, end);
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    final pipeline = JsonStreamPipeline.bind<MenuScannerRecord>(
      rawStream: createChunkStream(),
      mapper: MenuScannerPayloadParser.parseStreamingSnapshot,
      initialData: MenuScannerRecord.empty(),
      throttleDuration: const Duration(milliseconds: 50),
    );

    int snapshotCount = 0;
    final itemCounts = <int>[];

    await for (final snapshot in pipeline) {
      snapshotCount++;
      final count = snapshot.data.items.length;
      itemCounts.add(count);
      if (itemCounts.length == 1 || itemCounts.last != itemCounts[itemCounts.length - 2]) {
        print('Snapshot #$snapshotCount (isComplete=${snapshot.isComplete}): dishes=${snapshot.data.items.length}, store=${snapshot.data.storeName}');
      }
    }

    print('Total snapshots: $snapshotCount');
    print('Unique dish counts progression: ${itemCounts.toSet().toList()}');
  });
}
