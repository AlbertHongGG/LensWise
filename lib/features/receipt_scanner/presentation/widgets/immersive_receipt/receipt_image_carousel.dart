import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CarouselItem {
  final ImageProvider image;
  final BoxFit fit;
  const CarouselItem({required this.image, this.fit = BoxFit.fitWidth});
}

class ReceiptImageCarousel extends StatefulWidget {
  final List<CarouselItem> items;
  final ValueChanged<int>? onPageChanged;

  const ReceiptImageCarousel({
    super.key,
    required this.items,
    this.onPageChanged,
  });

  @override
  State<ReceiptImageCarousel> createState() => _ReceiptImageCarouselState();
}

class _ReceiptImageCarouselState extends State<ReceiptImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  late List<TransformationController> _transformControllers;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initControllers();
  }

  void _initControllers() {
    final count = widget.items.length;
    _transformControllers = List.generate(count, (_) => TransformationController());
    for (var controller in _transformControllers) {
      controller.addListener(_onScaleChanged);
    }
  }

  void _onScaleChanged() {
    if (_currentIndex < _transformControllers.length) {
      final scale = _transformControllers[_currentIndex].value.getMaxScaleOnAxis();
      final isZoomedIn = scale > 1.05; // Added slight margin
      if (isZoomedIn != _isZoomedIn) {
        setState(() {
          _isZoomedIn = isZoomedIn;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ReceiptImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final count = widget.items.length;
    if (_transformControllers.length != count) {
      if (count > _transformControllers.length) {
        // Add new controllers for newly added images
        for (int i = _transformControllers.length; i < count; i++) {
          final c = TransformationController();
          c.addListener(_onScaleChanged);
          _transformControllers.add(c);
        }
      } else {
        // Remove excess controllers
        while (_transformControllers.length > count) {
          final c = _transformControllers.removeLast();
          c.removeListener(_onScaleChanged);
          c.dispose();
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _transformControllers) {
      c.removeListener(_onScaleChanged);
      c.dispose();
    }
    super.dispose();
  }

  int get _itemCount => widget.items.length;

  CarouselItem _getItem(int index) {
    return widget.items[index];
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
          physics: _isZoomedIn 
              ? const NeverScrollableScrollPhysics() 
              : const _CarouselScrollPhysics(),
          controller: _pageController,
          itemCount: _itemCount,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            widget.onPageChanged?.call(index);
          },
          itemBuilder: (context, index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  transformationController: _transformControllers[index],
                  minScale: 1.0,
                  maxScale: 4.0,
                  constrained: false, // Core fix: allow child to exceed viewport natively
                  boundaryMargin: EdgeInsets.zero,
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight, // Centers the image if it's shorter than viewport
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(
                          image: _getItem(index).image,
                          fit: _getItem(index).fit,
                        ),
                      ),
                    ),
                  ),
                );
              },
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

class _CarouselScrollPhysics extends BouncingScrollPhysics {
  const _CarouselScrollPhysics({super.parent});

  @override
  _CarouselScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CarouselScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get dragStartDistanceMotionThreshold => 30.0; // High threshold so pinch-to-zoom wins easily over horizontal swipe
}

