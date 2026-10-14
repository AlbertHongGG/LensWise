import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';
import 'sse_decoder.dart';
import 'types.dart';

class GeminiFlowClient {
  final String baseUrl;
  final http.Client _httpClient;
  final bool _shouldCloseClient;

  GeminiFlowClient({
    String baseUrl = 'http://127.0.0.1:5000',
    http.Client? httpClient,
  })  : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _httpClient = httpClient ?? http.Client(),
        _shouldCloseClient = httpClient == null;

  /// Check whether the local GeminiFlow Ktor server is reachable and running.
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await _httpClient.get(url).timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data is Map && data['ok'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Sends a non-streaming chat request (`POST /chat`).
  Future<GeminiFlowChatResponse> chat(GeminiFlowChatRequest request) async {
    final url = Uri.parse('$baseUrl/chat');
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      _throwDetailedException(
        response.statusCode,
        utf8.decode(response.bodyBytes),
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! Map<String, dynamic>) {
      throw const GeminiFlowPayloadException('伺服器回傳格式不符合預期的 JSON 物件');
    }

    return GeminiFlowChatResponse.fromJson(data);
  }

  /// Initiates an SSE streaming chat session (`POST /stream`).
  Stream<GeminiFlowStreamChunk> stream(GeminiFlowChatRequest request) async* {
    final url = Uri.parse('$baseUrl/stream');
    final httpRequest = http.Request('POST', url);
    httpRequest.headers['Content-Type'] = 'application/json; charset=utf-8';
    httpRequest.body = jsonEncode(request.toJson());

    final streamedResponse = await _httpClient.send(httpRequest);

    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      _throwDetailedException(streamedResponse.statusCode, errorBody);
    }

    final sseStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .transform(const SseEventDecoder());

    await for (final event in sseStream) {
      switch (event.event) {
        case 'text':
          final chunkText = _extractTextFromData(event.data);
          if (chunkText.isNotEmpty) {
            yield GeminiFlowStreamChunk(text: chunkText);
          }
          break;

        case 'image':
          final imageUrl = _extractImageUrlFromData(event.data);
          if (imageUrl != null && imageUrl.isNotEmpty) {
            yield GeminiFlowStreamChunk(images: [imageUrl]);
          }
          break;

        case 'done':
          return;

        case 'error':
          final errorMsg = _extractErrorMessage(
            event.data,
            '串流過程中發生未知錯誤',
          );
          final statusCode = _extractStatusCode(event.data) ?? 500;
          _throwDetailedException(statusCode, errorMsg);

        default:
          // Fallback parsing for unknown or unlabelled message types
          final chunkText = _extractTextFromData(event.data);
          final imageUrl = _extractImageUrlFromData(event.data);
          if (chunkText.isNotEmpty || imageUrl != null) {
            yield GeminiFlowStreamChunk(
              text: chunkText,
              images: imageUrl != null ? [imageUrl] : const [],
            );
          }
          break;
      }
    }
  }

  void close() {
    if (_shouldCloseClient) {
      _httpClient.close();
    }
  }

  String _extractTextFromData(String dataStr) {
    if (dataStr.isEmpty) return '';
    try {
      final data = jsonDecode(dataStr);
      if (data is Map) {
        return (data['chunk'] ??
                data['text'] ??
                data['response'] ??
                data['content'] ??
                '')
            .toString();
      }
    } catch (_) {}
    return '';
  }

  String? _extractImageUrlFromData(String dataStr) {
    if (dataStr.isEmpty) return null;
    try {
      final data = jsonDecode(dataStr);
      if (data is Map) {
        final url = data['url'];
        if (url is String) return url;
        final images = data['images'];
        if (images is List && images.isNotEmpty) {
          return images.first.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  int? _extractStatusCode(String dataStr) {
    try {
      final data = jsonDecode(dataStr);
      if (data is Map && data['status'] is int) {
        return data['status'] as int;
      }
    } catch (_) {}
    return null;
  }

  String _extractErrorMessage(String body, [String fallback = '伺服器錯誤']) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'].toString();
      }
    } catch (_) {}
    return body.isNotEmpty ? body : fallback;
  }

  Never _throwDetailedException(int statusCode, String rawBody) {
    final message = _extractErrorMessage(rawBody);
    switch (statusCode) {
      case 400:
        throw GeminiFlowBadRequestException(message);
      case 401:
        throw GeminiFlowAuthException(
          message.isNotEmpty
              ? message
              : 'Google 帳號未授權或憑證已過期，請於手機端 GeminiFlow 重新登入',
        );
      case 422:
        throw GeminiFlowPayloadException(message);
      case 500:
      case 502:
        throw GeminiFlowServerException(message, statusCode);
      default:
        throw GeminiFlowException(message, statusCode);
    }
  }
}
