import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';

class ComparisonUnifiedBoard extends ConsumerWidget {
  final ProductComparisonRecord result;
  final int leftIndex;
  final int rightIndex;
  final bool isDark;
  final bool isStreaming;

  const ComparisonUnifiedBoard({
    super.key,
    required this.result,
    required this.leftIndex,
    required this.rightIndex,
    required this.isDark,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeStreaming = isStreaming ||
        ref.watch(productComparisonScannerControllerProvider.select((state) {
          return state.status == ProductComparisonStatus.streaming;
        }));

    final comparisonPoints = ref.watch(productComparisonScannerControllerProvider.select((state) {
      return state.parsingResult?.comparisonPoints ?? result.comparisonPoints;
    }));

    if (comparisonPoints.isEmpty) {
      if (!activeStreaming) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.only(top: 40, bottom: 24, left: 16, right: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
            width: 1,
          ),
        ),
        child: const Column(
          children: [
            StreamingSkeleton(width: double.infinity, height: 44, margin: EdgeInsets.only(bottom: 16)),
            StreamingSkeleton(width: double.infinity, height: 44, margin: EdgeInsets.only(bottom: 16)),
            StreamingSkeleton(width: double.infinity, height: 44, margin: EdgeInsets.only(bottom: 16)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // Add generous padding inside the board, especially at top for breathing room
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...List.generate(comparisonPoints.length, (index) {
            final point = comparisonPoints[index];
            final isLast = index == comparisonPoints.length - 1 && !activeStreaming;

            String leftVal = leftIndex < point.values.length ? point.values[leftIndex] : 'N/A';
            String rightVal = rightIndex < point.values.length ? point.values[rightIndex] : 'N/A';

            return KeyedSubtree(
              key: ValueKey('comparison_point_${point.aspect}_$index'),
              child: Column(
                children: [
                  ComparisonMatrixRow(
                    aspect: point.aspect,
                    leftValue: leftVal,
                    rightValue: rightVal,
                    isDark: isDark,
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                ],
              ),
            );
          }),
          if (activeStreaming) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                thickness: 1,
                height: 1,
              ),
            ),
            const StreamingSkeleton(
              width: double.infinity,
              height: 44,
              margin: EdgeInsets.only(bottom: 8),
            ),
          ],
        ],
      ),
    );
  }
}

class ComparisonMatrixRow extends StatelessWidget {
  final String aspect;
  final String leftValue;
  final String rightValue;
  final bool isDark;

  const ComparisonMatrixRow({
    super.key,
    required this.aspect,
    required this.leftValue,
    required this.rightValue,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Layer: Central Aspect Pill
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.blueAccent.withValues(alpha: 0.5) : Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 14,
                  color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    aspect,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bottom Layer: Split Values
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Value
              Expanded(
                child: Text(
                  leftValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VerticalDivider(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                  thickness: 1,
                  width: 1,
                ),
              ),

              // Right Value
              Expanded(
                child: Text(
                  rightValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
