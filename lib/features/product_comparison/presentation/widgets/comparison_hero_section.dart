import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonHeroSection extends StatelessWidget {
  final ComparisonResult result;
  final int leftIndex;
  final int rightIndex;
  final ImageProvider Function(int) imageProviderFactory;

  const ComparisonHeroSection({
    super.key,
    required this.result,
    required this.leftIndex,
    required this.rightIndex,
    required this.imageProviderFactory,
  });

  @override
  Widget build(BuildContext context) {
    Widget leftWidget = Image(image: imageProviderFactory(leftIndex), fit: BoxFit.cover, height: 220);
    Widget rightWidget = Image(image: imageProviderFactory(rightIndex), fit: BoxFit.cover, height: 220);

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      leftWidget,
                      _buildProductNameOverlay(leftIndex),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      rightWidget,
                      _buildProductNameOverlay(rightIndex),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // VS Badge (Premium Dark Glassmorphism)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Padding(
                    // Visual centering: nudge left to compensate for 'VS' optical weight imbalance and remove italic
                    padding: EdgeInsets.only(right: 2.0),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductNameOverlay(int index) {
    if (result.products.isEmpty || index >= result.products.length) return const SizedBox.shrink();
    final product = result.products[index];
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.translatedName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.originalName.isNotEmpty && product.originalName != product.translatedName)
              Text(
                product.originalName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
