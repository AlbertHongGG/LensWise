import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/domain/exceptions/ai_connection_error.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/image_encoder.dart';

class VertexAIProvider with AIImageEncoderMixin implements AIProvider {
  @override
  final String name = 'vertexai';

  final String _model;
  final String _projectId;
  final String _region;
  final String _accessToken;

  VertexAIProvider({
    required String modelName,
    required String projectId,
    required String region,
    required String accessToken,
  }) : _model = modelName,
       _projectId = projectId,
       _region = region,
       _accessToken = accessToken;

  @override
  Future<GenerateResponse> generate(GenerateRequest request) async {
    try {
      final url = Uri.parse(
        'https://$_region-aiplatform.googleapis.com/v1/projects/$_projectId/locations/$_region/publishers/google/models/$_model:generateContent',
      );

      final body = _buildBody(request);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Vertex AI API error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      String text = _extractTextFromResponse(data);

      return GenerateResponse(text: text);
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    }
  }

  @override
  Stream<GenerateResponse> generateStream(GenerateRequest request) async* {
    final url = Uri.parse(
      'https://$_region-aiplatform.googleapis.com/v1/projects/$_projectId/locations/$_region/publishers/google/models/$_model:streamGenerateContent?alt=sse',
    );
    final client = http.Client();
    try {
      final httpRequest = http.Request('POST', url);
      httpRequest.headers['Authorization'] = 'Bearer $_accessToken';
      httpRequest.headers['Content-Type'] = 'application/json';

      httpRequest.body = jsonEncode(_buildBody(request));

      final response = await client.send(httpRequest);

      if (response.statusCode != 200) {
        throw Exception('Vertex AI API error: ${response.statusCode}');
      }

      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('data: ')) {
          final jsonString = trimmed.substring(6).trim();
          if (jsonString.isEmpty) continue;

          try {
            final data = jsonDecode(jsonString);
            String text = _extractTextFromResponse(data);
            if (text.isNotEmpty) {
              yield GenerateResponse(text: text);
            }
          } catch (_) {
            // Ignore parse errors on partial SSE chunks
          }
        }
      }
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    } finally {
      client.close();
    }
  }

  Map<String, dynamic> _buildBody(GenerateRequest request) {
    final parts = <Map<String, dynamic>>[
      {'text': request.prompt},
    ];

    final base64Images = encodeImagesToBase64(request);
    if (base64Images != null) {
      for (final base64String in base64Images) {
        parts.add({
          'inlineData': {'mimeType': 'image/jpeg', 'data': base64String},
        });
      }
    }

    final Map<String, dynamic> body = {
      'contents': [
        {'role': 'user', 'parts': parts},
      ],
    };

    if (request.systemPrompt != null && request.systemPrompt!.isNotEmpty) {
      body['systemInstruction'] = {
        'role': 'system',
        'parts': [
          {'text': request.systemPrompt},
        ],
      };
    }

    return body;
  }

  String _extractTextFromResponse(Map<String, dynamic> data) {
    String text = '';
    if (data['candidates'] != null && (data['candidates'] as List).isNotEmpty) {
      final content = data['candidates'][0]['content'];
      if (content != null &&
          content['parts'] != null &&
          (content['parts'] as List).isNotEmpty) {
        text = content['parts'][0]['text'] ?? '';
      }
    }
    return text;
  }
}
