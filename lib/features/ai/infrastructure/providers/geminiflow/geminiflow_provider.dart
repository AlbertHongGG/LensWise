import 'package:lens_wise/features/ai/domain/exceptions/ai_connection_error.dart';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/ai_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/image_encoder.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/client.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/exceptions.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

class GeminiFlowProvider with AIImageEncoderMixin implements AIProvider {
  @override
  final String name = 'geminiflow';

  final GeminiFlowClient _client;
  final String _model;
  final GeminiThinkingLevel _thinking;

  GeminiFlowProvider({
    required String modelName,
    required String baseUrl,
    this._thinking = GeminiThinkingLevel.low,
    GeminiFlowClient? client,
  })  : _model = modelName.isNotEmpty ? modelName : GeminiFlowModel.flash,
        _client = client ?? GeminiFlowClient(baseUrl: baseUrl);

  @override
  Future<GenerateResponse> generate(GenerateRequest request) async {
    try {
      final chatRequest = GeminiFlowChatRequest(
        prompt: request.prompt,
        systemPrompt: request.systemPrompt,
        model: _model,
        thinking: _thinking,
        images: encodeImagesToBase64(request),
      );

      final response = await _client.chat(chatRequest);

      return GenerateResponse(
        text: response.text,
        images: response.images.map(_mapImageResponse).toList(),
      );
    } on GeminiFlowException catch (e) {
      throw AIConnectionError(name, e.message);
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    }
  }

  @override
  Stream<GenerateResponse> generateStream(GenerateRequest request) async* {
    try {
      final chatRequest = GeminiFlowChatRequest(
        prompt: request.prompt,
        systemPrompt: request.systemPrompt,
        model: _model,
        thinking: _thinking,
        images: encodeImagesToBase64(request),
      );

      final stream = _client.stream(chatRequest);

      await for (final chunk in stream) {
        final mappedImages = chunk.images.map(_mapImageResponse).toList();
        yield GenerateResponse(
          text: chunk.text,
          images: mappedImages.isNotEmpty ? mappedImages : null,
        );
      }
    } on GeminiFlowException catch (e) {
      throw AIConnectionError(name, e.message);
    } catch (e) {
      throw AIConnectionError(name, e.toString());
    }
  }

  AIImageResponse _mapImageResponse(String img) {
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return AIUrlImageResponse(img);
    }
    return AIBase64ImageResponse(img);
  }
}
