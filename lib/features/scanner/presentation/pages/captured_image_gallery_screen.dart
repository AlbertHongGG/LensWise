import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/scanner_controller.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class CapturedImageGalleryScreen extends ConsumerStatefulWidget {
  const CapturedImageGalleryScreen({super.key});

  @override
  ConsumerState<CapturedImageGalleryScreen> createState() => _CapturedImageGalleryScreenState();
}

class _CapturedImageGalleryScreenState extends ConsumerState<CapturedImageGalleryScreen> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    // Use read to get initial state
    final images = ref.read(scannerControllerProvider).capturedImages;
    final initialPage = images.isNotEmpty ? images.length - 1 : 0;
    _pageController = PageController(initialPage: initialPage);
    _currentIndex = ValueNotifier(initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  void _onImageDeleted(int index, int totalImages) {
    ref.read(scannerControllerProvider.notifier).removeImage(index);
    if (totalImages <= 1) { // 1 because we are removing the last one
      Navigator.of(context).pop(); // Auto-close if no images left
    } else {
      // Adjust current index if needed
      if (_currentIndex.value >= totalImages - 1) {
        _currentIndex.value = totalImages - 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(scannerControllerProvider).capturedImages;

    return Scaffold(
      backgroundColor: Colors.black,
      body: images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                              onPressed: () => _onImageDeleted(index, images.length),
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
                        final screenSize = MediaQuery.of(context).size;
                        final screenRatio = screenSize.width / screenSize.height;
                        final imageEntity = images[index];
                        final isCamera = imageEntity.source == ImageSourceType.camera;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: screenRatio,
                                child: Image.memory(
                                  imageEntity.bytes,
                                  fit: isCamera ? BoxFit.cover : BoxFit.contain,
                                ),
                              ),
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
                                    images[index].bytes,
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
            ),
    );
  }
}
