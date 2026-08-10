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
      margin: const EdgeInsets.only(bottom: 24, top: 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Content Card
          Container(
            margin: const EdgeInsets.only(top: 16), // Push down to let badge overlap
            padding: const EdgeInsets.only(top: 36, bottom: 24, left: 20, right: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Text(
                      leftVal,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: VerticalDivider(
                      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                      thickness: 1,
                      width: 1,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rightVal,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlapping Title Badge (Focal Point)
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30),
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
                    size: 16,
                    color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    point.aspect,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.blueAccent.shade100 : Colors.blue.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
