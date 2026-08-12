import 'dart:convert';
import 'package:lens_wise/features/ai/domain/models/generate_request.dart';

/// Standardized Image Encoder for AI Providers
/// Ensures a consistent way of transforming raw image bytes to Base64 strings.
mixin AIImageEncoderMixin {
  /// Extracts images from a GenerateRequest and converts them to a list of Base64 strings.
  List<String>? encodeImagesToBase64(GenerateRequest request) {
    if (request.images == null || request.images!.isEmpty) {
      return null;
    }

    return request.images!.map((bytes) => base64Encode(bytes)).toList();
  }
}
