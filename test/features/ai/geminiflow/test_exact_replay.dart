import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/client.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

void main() {
  test('Exact replay of log_051537 to measure real SSE chunk arrival timing', () async {
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
    final reqMap = logMap['request'] as Map<String, dynamic>;

    final prompt = reqMap['prompt'] as String;
    final systemPrompt = reqMap['system_prompt'] as String? ?? reqMap['systemPrompt'] as String?;
    final images = (reqMap['images'] as List).cast<String>();

    print('Replaying real request: prompt length=${prompt.length}, systemPrompt length=${systemPrompt?.length}, images=${images.length}');

    final client = GeminiFlowClient(baseUrl: 'http://127.0.0.1:5000');
    final chatReq = GeminiFlowChatRequest(
      prompt: prompt,
      systemPrompt: systemPrompt,
      images: images,
      model: 'gemini-3.8-flash',
      thinking: GeminiThinkingLevel.low,
    );

    final sw = Stopwatch()..start();
    print('Sending stream request at ${DateTime.now()}');

    int chunkIndex = 0;
    final stream = client.stream(chatReq);

    await for (final chunk in stream) {
      chunkIndex++;
      final ms = sw.elapsedMilliseconds;
      final textPreview = chunk.text.length > 40 ? '${chunk.text.substring(0, 40)}...' : chunk.text;
      print('[$ms ms] Chunk #$chunkIndex (len ${chunk.text.length}): ${jsonEncode(textPreview)}');
    }

    print('TOTAL TIME: ${sw.elapsedMilliseconds} ms. Total chunks: $chunkIndex');
  }, timeout: const Timeout(Duration(minutes: 2)));
}
