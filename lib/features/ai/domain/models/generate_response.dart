import 'dart:typed_data';

abstract class AIImageResponse {}

class AIUrlImageResponse extends AIImageResponse {
  final String url;
  AIUrlImageResponse(this.url);
}

class AIBase64ImageResponse extends AIImageResponse {
  final String base64String;
  AIBase64ImageResponse(this.base64String);
}

class AIBytesImageResponse extends AIImageResponse {
  final Uint8List bytes;
  AIBytesImageResponse(this.bytes);
}

class GenerateResponse {
  final String text;
  final List<AIImageResponse>? images;

  GenerateResponse({required this.text, this.images});
}
