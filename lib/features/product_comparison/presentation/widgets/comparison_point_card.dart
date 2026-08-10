import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonPointCard extends StatelessWidget {
  final ComparisonPoint point;
  final int leftIndex;
  final int rightIndex;
  final bool isDark;

  const ComparisonPointCard({
    super.key,
    required this.point,
    required this.leftIndex,
    required this.rightIndex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String leftVal = 'N/A';
    String rightVal = 'N/A';

    if (leftIndex < point.values.length) leftVal = point.values[leftIndex];
    if (rightIndex < point.values.length) rightVal = point.values[rightIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          // Aspect Title (Balance Pivot)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
            ),
            child: Text(
              point.aspect,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Left vs Right detailed values
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      leftVal,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                VerticalDivider(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1,
                  thickness: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      rightVal,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
