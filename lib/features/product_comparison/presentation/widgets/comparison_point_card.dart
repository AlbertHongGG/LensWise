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
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Elegant floating pill for Aspect Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              point.aspect,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Left vs Right detailed values (No rigid borders, just clean spacing)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  leftVal,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 32), // Elegant spacing instead of a rigid line
              Expanded(
                child: Text(
                  rightVal,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            height: 1,
          ),
        ],
      ),
    );
  }
}
