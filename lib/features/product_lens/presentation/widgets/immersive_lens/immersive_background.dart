import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:lens_wise/core/models/app_image_entity.dart';

class ImmersiveBackground extends StatefulWidget {
  final List<AppImageEntity>? appImages;
  final List<String> imagePaths;

  const ImmersiveBackground({
    super.key,
    this.appImages,
    this.imagePaths = const [],
  });

  @override
  State<ImmersiveBackground> createState() => _ImmersiveBackgroundState();
}

class _ImmersiveBackgroundState extends State<ImmersiveBackground> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasBytes =
        widget.appImages != null && widget.appImages!.isNotEmpty;
    final hasPaths = widget.imagePaths.isNotEmpty;
    final itemCount = hasBytes
        ? widget.appImages!.length
        : (hasPaths ? widget.imagePaths.length : 0);

    if (itemCount == 0) {
      return Container(color: isDark ? Colors.grey[900] : Colors.grey[300]);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (hasBytes) {
              final imageEntity = widget.appImages![index];
              return Image.memory(
                imageEntity.bytes,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              );
            } else {
              return Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              );
            }
          },
        ),

        // Page Indicator
        if (itemCount > 1)
          Positioned(
            bottom:
                MediaQuery.of(context).size.height *
                0.08, // Adjust based on bottom card overlap
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                itemCount,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
