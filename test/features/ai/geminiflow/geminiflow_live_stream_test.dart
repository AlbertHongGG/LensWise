import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/client.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

void main() {
  test('Live GeminiFlow /stream test on device measures chunk timing', () async {
    final client = GeminiFlowClient(baseUrl: 'http://127.0.0.1:5000');
    final isAlive = await client.checkHealth();
    print('Health check: $isAlive (status 200 returned {})');

    final req = const GeminiFlowChatRequest(
      model: 'gemini-3.8-flash',
      prompt: '請用繁體中文列出 5 種台灣夜市小吃，以 JSON 格式回傳，包含 name 和 description 欄位。',
      thinking: GeminiThinkingLevel.low,
    );

    final sw = Stopwatch()..start();
    print('Starting stream at ${DateTime.now()}');

    int chunkIndex = 0;
    final stream = client.stream(req);

    await for (final chunk in stream) {
      chunkIndex++;
      final ms = sw.elapsedMilliseconds;
      print('[$ms ms] Chunk #$chunkIndex: ${jsonEncode(chunk.text)}');
    }

    print('Stream finished in ${sw.elapsedMilliseconds} ms. Total chunks: $chunkIndex');
    expect(chunkIndex, greaterThan(0));
  }, timeout: const Timeout(Duration(seconds: 45)), skip: 'Requires live GeminiFlow daemon running on port 5000');
}
