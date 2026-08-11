import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ReceiptImageCarousel extends StatefulWidget {
  final List<Uint8List> memoryImages;
  final List<String> filePaths;

  const ReceiptImageCarousel({
    super.key,
    this.memoryImages = const [],
    this.filePaths = const [],
  });

  @override
  State<ReceiptImageCarousel> createState() => _ReceiptImageCarouselState();
}

class _ReceiptImageCarouselState extends State<ReceiptImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _itemCount => widget.memoryImages.isNotEmpty ? widget.memoryImages.length : widget.filePaths.length;

  ImageProvider _getImageProvider(int index) {
    if (widget.memoryImages.isNotEmpty) {
      return MemoryImage(widget.memoryImages[index]);
    } else {
      return FileImage(File(widget.filePaths[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_itemCount == 0) {
      return Container(
        color: const Color(0xFF1E1E1E),
        child: const Center(
          child: Icon(Icons.receipt_long, size: 64, color: Colors.white24),
        ),
      );
    }

    return Stack(
      children: [
        Container(color: Colors.black), // Base background
        PageView.builder(
          controller: _pageController,
          itemCount: _itemCount,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image(
                      image: _getImageProvider(index),
                      fit: BoxFit.contain, // Professional un-clipped view
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Pagination Dots
        if (_itemCount > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _itemCount,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.white38,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
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
