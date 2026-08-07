import 'dart:typed_data';

class GenerateRequest {
  final String prompt;
  final String? systemPrompt;
  final List<Uint8List>? images;

  GenerateRequest({
    required this.prompt,
    this.systemPrompt,
    this.images,
  });
}
