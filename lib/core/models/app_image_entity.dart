import 'dart:typed_data';

enum ImageSourceType { camera, gallery, ai }

class AppImageEntity {
  final Uint8List bytes;
  final ImageSourceType source;
  final String? path;

  const AppImageEntity({
    required this.bytes,
    required this.source,
    this.path,
  });

  AppImageEntity copyWith({
    Uint8List? bytes,
    ImageSourceType? source,
    String? path,
  }) {
    return AppImageEntity(
      bytes: bytes ?? this.bytes,
      source: source ?? this.source,
      path: path ?? this.path,
    );
  }
}
