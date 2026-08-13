import 'dart:typed_data';

class GenerateResponse {
  final String text;
  final List<Uint8List>? images;

  GenerateResponse({required this.text, this.images});
}
