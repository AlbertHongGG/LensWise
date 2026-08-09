import 'package:flutter/material.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';

class CapturedImageGalleryScreen extends StatefulWidget {
  final ScannerModeStrategy strategy;

  const CapturedImageGalleryScreen({
    super.key,
    required this.strategy,
  });

  @override
  State<CapturedImageGalleryScreen> createState() => _CapturedImageGalleryScreenState();
}

class _CapturedImageGalleryScreenState extends State<CapturedImageGalleryScreen> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    // Start at the last captured image
    final initialPage = widget.strategy.capturedImages.value.isNotEmpty 
        ? widget.strategy.capturedImages.value.length - 1 
        : 0;
    _pageController = PageController(initialPage: initialPage);
    _currentIndex = ValueNotifier(initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _onImageDeleted(int index) {
    widget.strategy.removeImage(index);
    if (widget.strategy.capturedImages.value.isEmpty) {
      Navigator.of(context).pop(); // Auto-close if no images left
    } else {
      // Adjust current index if needed
      if (_currentIndex.value >= widget.strategy.capturedImages.value.length) {
        _currentIndex.value = widget.strategy.capturedImages.value.length - 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: widget.strategy.capturedImages,
        builder: (context, images, child) {
          if (images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                // 1. Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _currentIndex,
                        builder: (context, index, child) {
                          return Text(
                            '${index + 1} / ${images.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _currentIndex,
                        builder: (context, index, child) {
                          return IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _onImageDeleted(index),
                          );
                        }
                      ),
                    ],
                  ),
                ),

                // 2. Main Full-Screen Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      _currentIndex.value = index;
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Bottom Thumbnail Carousel
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return ValueListenableBuilder<int>(
                        valueListenable: _currentIndex,
                        builder: (context, currentIndex, child) {
                          final isSelected = currentIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                left: index == 0 ? 16 : 8,
                                right: index == images.length - 1 ? 16 : 8,
                              ),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 4)]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
