import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/domain/exceptions/ai_connection_error.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/image_encoder.dart';

class OllamaProvider with AIImageEncoderMixin implements AIProvider {
  @override
  final String name = 'ollama';

  final String _model;
  final String _baseUrl;

  OllamaProvider({required String modelName, required String baseUrl})
    : _model = modelName,
      _baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;

  @override
  Future<GenerateResponse> generate(GenerateRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl/api/generate');

      final Map<String, dynamic> body = {
        'model': _model,
        'prompt': request.prompt,
        'stream': false,
      };

      if (request.systemPrompt != null) {
        body['system'] = request.systemPrompt;
      }

      final base64Images = encodeImagesToBase64(request);
      if (base64Images != null) {
        body['images'] = base64Images;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Ollama API error: ${response.statusCode}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return GenerateResponse(text: data['response'] ?? '');
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    }
  }

  @override
  Stream<GenerateResponse> generateStream(GenerateRequest request) async* {
    final url = Uri.parse('$_baseUrl/api/generate');
    final client = http.Client();
    try {
      final httpRequest = http.Request('POST', url);
      httpRequest.headers['Content-Type'] = 'application/json';

      final Map<String, dynamic> body = {
        'model': _model,
        'prompt': request.prompt,
        'stream': true,
      };

      if (request.systemPrompt != null) {
        body['system'] = request.systemPrompt;
      }

      final base64Images = encodeImagesToBase64(request);
      if (base64Images != null) {
        body['images'] = base64Images;
      }

      httpRequest.body = jsonEncode(body);

      final response = await client.send(httpRequest);

      if (response.statusCode != 200) {
        throw Exception('Ollama API error: ${response.statusCode}');
      }

      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final data = jsonDecode(trimmed);
          yield GenerateResponse(text: data['response'] ?? '');
        } catch (_) {
          // Ignore parse errors on partial lines
        }
      }
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    } finally {
      client.close();
    }
  }
}
