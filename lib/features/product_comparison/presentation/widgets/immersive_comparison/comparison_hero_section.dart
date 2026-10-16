import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';

class ComparisonHeroSection extends ConsumerWidget {
  final ProductComparisonRecord result;
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
  Widget build(BuildContext context, WidgetRef ref) {
    Widget leftWidget = Image(image: imageProviderFactory(leftIndex), fit: BoxFit.cover, height: 220);
    Widget rightWidget = Image(image: imageProviderFactory(rightIndex), fit: BoxFit.cover, height: 220);

    // Fine-grained selector: Only rebuilds when the visible pair's names change!
    final products = ref.watch(productComparisonScannerControllerProvider.select((state) {
      final rec = state.parsingResult ?? result;
      final leftProd = leftIndex < rec.products.length ? rec.products[leftIndex] : null;
      final rightProd = rightIndex < rec.products.length ? rec.products[rightIndex] : null;
      return (
        leftName: leftProd?.translatedName ?? '',
        leftOriginal: leftProd?.originalName ?? '',
        rightName: rightProd?.translatedName ?? '',
        rightOriginal: rightProd?.originalName ?? '',
      );
    }));

    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        leftWidget,
                        _buildProductNameOverlay(products.leftName, products.leftOriginal),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        rightWidget,
                        _buildProductNameOverlay(products.rightName, products.rightOriginal),
                      ],
                    ),
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

  Widget _buildProductNameOverlay(String translatedName, String originalName) {
    if (translatedName.isEmpty && originalName.isEmpty) return const SizedBox.shrink();

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
              translatedName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (originalName.isNotEmpty && originalName != translatedName)
              Text(
                originalName,
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
