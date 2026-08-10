import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonProductCarousel extends StatelessWidget {
  final List<ComparisonProduct> products;
  final ImageProvider Function(int) imageProviderFactory;

  const ComparisonProductCarousel({
    super.key,
    required this.products,
    required this.imageProviderFactory,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140, // Fixed height for horizontal rectangular cards
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none, // Allow shadows to overflow
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _CarouselProductCard(
            product: products[index],
            imageProvider: imageProviderFactory(index),
          );
        },
      ),
    );
  }
}

class _CarouselProductCard extends StatelessWidget {
  final ComparisonProduct product;
  final ImageProvider imageProvider;

  const _CarouselProductCard({
    required this.product,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // 220x140 is roughly 1.57 ratio (close to 16:10)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image Layer
            Image(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            
            // 2. Premium Dark Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            // 3. Text Content Layer (Bottom aligned)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.translatedName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.originalName.isNotEmpty && product.originalName != product.translatedName) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.originalName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
