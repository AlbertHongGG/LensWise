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
            )
          else if (imagePath != null && imagePath!.isNotEmpty)
            Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
            )
          else
            Container(color: isDark ? Colors.grey[900] : Colors.grey[300]),
            
          // Massive smooth gradient overlay to perfectly blend the image into the background color
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withValues(alpha: 0.1), // Very light at top
                  backgroundColor.withValues(alpha: 0.3),
                  backgroundColor.withValues(alpha: 0.8),
                  backgroundColor,
                  backgroundColor, // Solid at bottom to hide the image edge
                ],
                stops: const [0.0, 0.4, 0.7, 0.9, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
