import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class HeroTitleOverlay extends ConsumerWidget {
  final ProductLensRecord? initialRecord;
  final String? productName;
  final String? originalName;
  final String? brand;
  final String? origin;
  final bool isLiveSession;

  const HeroTitleOverlay({
    super.key,
    this.initialRecord,
    this.productName,
    this.originalName,
    this.brand,
    this.origin,
    this.isLiveSession = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fallbackData = (
      productName: productName ?? initialRecord?.productName ?? '',
      originalName: originalName ?? initialRecord?.originalName ?? '',
      brand: brand ?? initialRecord?.brand ?? '',
      origin: origin ?? initialRecord?.origin ?? '',
    );

    // Fine-grained selector: Only rebuilds when title/brand/origin values actually change in live mode!
    final titleData = isLiveSession
        ? ref.watch(productLensControllerProvider.select((state) {
            final res = state.result;
            if (res != null) {
              return (
                productName: res.productName,
                originalName: res.originalName,
                brand: res.brand,
                origin: res.origin,
              );
            }
            return fallbackData;
          }))
        : fallbackData;

    final effectiveProductName = titleData.productName;
    final effectiveOriginalName = titleData.originalName;
    final effectiveBrand = titleData.brand;
    final effectiveOrigin = titleData.origin;

    if (effectiveProductName.isEmpty) {
      if (!isLiveSession) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            StreamingSkeleton(
              width: 110,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            SizedBox(height: 14),
            StreamingSkeleton(width: 240, height: 34),
            SizedBox(height: 10),
            StreamingSkeleton(width: 150, height: 18),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand & Origin Tag
          if (effectiveBrand.isNotEmpty || effectiveOrigin.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${effectiveBrand.isEmpty ? "未知品牌" : effectiveBrand} ${effectiveOrigin.isNotEmpty ? "· $effectiveOrigin" : ""}'
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),

          // Translated Product Name (Strict Single Line with Auto-Scaling)
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                effectiveProductName,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF111418),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Original Name (Strict Single Line with Auto-Scaling)
          if (effectiveOriginalName.isNotEmpty && effectiveOriginalName != effectiveProductName)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    effectiveOriginalName,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
