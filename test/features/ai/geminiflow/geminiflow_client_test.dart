import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/client.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/exceptions.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

void main() {
  group('GeminiFlowClient - Health Check', () {
    test('checkHealth returns true when status 200 with ok: true', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/health');
        return http.Response(jsonEncode({'ok': true}), 200);
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final isHealthy = await client.checkHealth();
      expect(isHealthy, isTrue);
    });

    test('checkHealth returns false when server returns 500 or error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final isHealthy = await client.checkHealth();
      expect(isHealthy, isFalse);
    });
  });

  group('GeminiFlowClient - Chat', () {
    test('chat sends valid JSON and returns GeminiFlowChatResponse', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/chat');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['prompt'], '哈囉');
        expect(body['model'], 'gemini-3.8-flash');
        expect(body['thinking'], 'low');
        expect(body['language'], 'zh-TW');
        expect(body['auto_refresh_cookies'], true);

        return http.Response(
          jsonEncode({
            'text': '你好！有什麼我可以幫忙的？',
            'images': ['http://127.0.0.1:5000/images/sample.png'],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final response = await client.chat(
        const GeminiFlowChatRequest(prompt: '哈囉'),
      );

      expect(response.text, '你好！有什麼我可以幫忙的？');
      expect(response.images, ['http://127.0.0.1:5000/images/sample.png']);
    });

    test('chat throws GeminiFlowAuthException on HTTP 401', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': '憑證過期'}),
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      expect(
        () => client.chat(const GeminiFlowChatRequest(prompt: '測試')),
        throwsA(isA<GeminiFlowAuthException>()),
      );
    });

    test('chat throws GeminiFlowBadRequestException on HTTP 400', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': '缺少模型參數 (model)'}),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      expect(
        () => client.chat(const GeminiFlowChatRequest(prompt: '測試')),
        throwsA(isA<GeminiFlowBadRequestException>()),
      );
    });
  });

  group('GeminiFlowClient - Stream & SSE', () {
    test('stream decodes text and image events correctly without dropping images', () async {
      final ssePayload = '''
event: text
data: {"chunk":"正在為您生成圖片..."}

event: image
data: {"url":"http://127.0.0.1:5000/images/dog_on_mars.png"}

event: text
data: {"chunk":"生成完畢！"}

event: done
data: {}
''';

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/stream');
        return http.Response(
          ssePayload,
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final chunks = await client
          .stream(
            const GeminiFlowChatRequest(
              prompt: '畫一隻在火星上的柴犬',
              model: GeminiFlowModel.pro,
            ),
          )
          .toList();

      expect(chunks.length, 3);
      expect(chunks[0].text, '正在為您生成圖片...');
      expect(chunks[0].images, isEmpty);

      // Verify that image URL is properly parsed and not dropped!
      expect(chunks[1].text, '');
      expect(chunks[1].images, [
        'http://127.0.0.1:5000/images/dog_on_mars.png',
      ]);

      expect(chunks[2].text, '生成完畢！');
    });

    test('stream throws GeminiFlowAuthException when SSE sends event: error with status 401', () async {
      final ssePayload = '''
event: error
data: {"error":"Google Session 已過期","status":401}
''';

      final mockClient = MockClient((request) async {
        return http.Response(
          ssePayload,
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      expect(
        () async => await client
            .stream(const GeminiFlowChatRequest(prompt: '測試'))
            .toList(),
        throwsA(isA<GeminiFlowAuthException>()),
      );
    });
  });
}
