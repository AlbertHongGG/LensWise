import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/utils/session_image_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyBytes1 = Uint8List.fromList([1, 2, 3, 4]);
  final dummyBytes2 = Uint8List.fromList([5, 6, 7, 8]);

  final memoryEntities = [
    AppImageEntity(bytes: dummyBytes1, source: ImageSourceType.camera),
    AppImageEntity(bytes: dummyBytes2, source: ImageSourceType.gallery),
  ];

  group('SessionImageResolver', () {
    test('Live Session (Memory Images) has precedence', () {
      final resolver = SessionImageResolver(
        memoryImages: memoryEntities,
        imagePaths: ['disk1.jpg', 'disk2.jpg'],
      );

      expect(resolver.isMemorySource, isTrue);
      expect(resolver.hasImages, isTrue);
      expect(resolver.count, equals(2));

      final provider = resolver.resolve(0);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<MemoryImage>());
      final memoryImg = resize.imageProvider as MemoryImage;
      expect(memoryImg.bytes, equals(dummyBytes1));
    });

    test('Clamps index safely when index exceeds memoryImages count', () {
      final resolver = SessionImageResolver(
        memoryImages: memoryEntities,
      );

      // index 10 should clamp to last element (index 1)
      final provider = resolver.resolve(10);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<MemoryImage>());
      final memoryImg = resize.imageProvider as MemoryImage;
      expect(memoryImg.bytes, equals(dummyBytes2));
    });

    test('History Mode (Disk Paths) resolves to FileImage via strategy injection', () {
      final resolver = SessionImageResolver(
        memoryImages: null,
        imagePaths: ['receipt_001.jpg', 'receipt_002.jpg'],
        fileResolver: (filename) => File('/isolated/test/media/$filename'),
      );

      expect(resolver.isMemorySource, isFalse);
      expect(resolver.hasImages, isTrue);
      expect(resolver.count, equals(2));

      final provider = resolver.resolve(1);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<FileImage>());
      final fileImg = resize.imageProvider as FileImage;
      expect(fileImg.file.path, contains('receipt_002.jpg'));
      expect(fileImg.file.path, contains('/isolated/test/media/'));
    });

    test('resolveDiskImage uses custom fileResolver without modifying global state', () {
      final resolver = SessionImageResolver(
        fileResolver: (filename) => File('/custom/sandbox/$filename'),
      );

      final provider = resolver.resolveDiskImage('menu_translated.jpg');
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<FileImage>());
      final fileImg = resize.imageProvider as FileImage;
      expect(fileImg.file.path, contains('/custom/sandbox/menu_translated.jpg'));

      final file = resolver.getFile('test.jpg');
      expect(file.path, equals('/custom/sandbox/test.jpg'));
    });

    test('Graceful fallback when completely empty (0 images)', () {
      final resolver = const SessionImageResolver(
        memoryImages: [],
        imagePaths: [],
      );

      expect(resolver.isMemorySource, isFalse);
      expect(resolver.hasImages, isFalse);
      expect(resolver.count, equals(0));

      final provider = resolver.resolve(0);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<MemoryImage>());
      final memImg = resize.imageProvider as MemoryImage;
      expect(memImg.bytes, equals(kTransparentImageBytes));
    });

    test('Graceful fallback when path is empty string', () {
      final resolver = const SessionImageResolver(
        imagePaths: [''],
      );

      expect(resolver.hasImages, isTrue);
      final provider = resolver.resolve(0);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.imageProvider, isA<MemoryImage>());
      final memImg = resize.imageProvider as MemoryImage;
      expect(memImg.bytes, equals(kTransparentImageBytes));
    });
  });
}
