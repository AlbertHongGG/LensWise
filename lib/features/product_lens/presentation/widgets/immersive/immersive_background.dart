import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImmersiveBackground extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imagePath;

  const ImmersiveBackground({super.key, this.imageBytes, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : const Color(0xFFF5F5F5);

    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageBytes != null)
            Image.memory(
              imageBytes!,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
          else if (imagePath != null && imagePath!.isNotEmpty)
            Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
          else
            Container(color: isDark ? Colors.grey[900] : Colors.grey[300]),
        ],
      ),
    );
  }
}
