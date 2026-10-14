import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lens_wise/features/ai/domain/exceptions/ai_connection_error.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/geminiflow_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/client.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

void main() {
  group('GeminiFlowProvider Tests', () {
    test('generate() returns GenerateResponse with text and AIUrlImageResponse', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'text': '已為您生成圖像',
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

      final provider = GeminiFlowProvider(
        modelName: GeminiFlowModel.pro,
        baseUrl: 'http://127.0.0.1:5000',
        thinking: GeminiThinkingLevel.high,
        client: client,
      );

      final response = await provider.generate(
        GenerateRequest(prompt: '請畫一隻貓咪'),
      );

      expect(response.text, '已為您生成圖像');
      expect(response.images, isNotNull);
      expect(response.images!.length, 1);
      expect(response.images!.first, isA<AIUrlImageResponse>());
      expect((response.images!.first as AIUrlImageResponse).url, 'http://127.0.0.1:5000/images/sample.png');
    });

    test('generateStream() yields GenerateResponse with text chunks and AIUrlImageResponse', () async {
      final sseData = '''
event: text
data: {"chunk":"正在繪製..."}

event: image
data: {"url":"http://127.0.0.1:5000/images/cat.png"}

event: text
data: {"chunk":"繪製完成"}

event: done
data: {}
''';

      final mockClient = MockClient((request) async {
        return http.Response(
          sseData,
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final provider = GeminiFlowProvider(
        modelName: GeminiFlowModel.pro,
        baseUrl: 'http://127.0.0.1:5000',
        client: client,
      );

      final responses = await provider.generateStream(
        GenerateRequest(prompt: '請畫一隻貓咪'),
      ).toList();

      expect(responses.length, 3);
      expect(responses[0].text, '正在繪製...');
      expect(responses[0].images, isNull);

      expect(responses[1].text, '');
      expect(responses[1].images, isNotNull);
      expect(responses[1].images!.first, isA<AIUrlImageResponse>());
      expect((responses[1].images!.first as AIUrlImageResponse).url, 'http://127.0.0.1:5000/images/cat.png');

      expect(responses[2].text, '繪製完成');
    });

    test('generate() maps GeminiFlowException to AIConnectionError with friendly message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': '未授權'}),
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = GeminiFlowClient(
        baseUrl: 'http://127.0.0.1:5000',
        httpClient: mockClient,
      );

      final provider = GeminiFlowProvider(
        modelName: GeminiFlowModel.flash,
        baseUrl: 'http://127.0.0.1:5000',
        client: client,
      );

      expect(
        () => provider.generate(GenerateRequest(prompt: '哈囉')),
        throwsA(isA<AIConnectionError>()),
      );
    });
  });
}
