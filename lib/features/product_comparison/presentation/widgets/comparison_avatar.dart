import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';

class ComparisonAvatar extends StatelessWidget {
  final ImageProvider image;
  final bool isSelected;
  final bool isLeft;
  final bool isDark;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  const ComparisonAvatar({
    super.key,
    required this.image,
    required this.isSelected,
    required this.isLeft,
    required this.isDark,
    required this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        // Absolutely responsive: no hardcoded sizes!
        child: AspectRatio(
          aspectRatio: 1.0, // Guarantees a perfect square to prevent oval fallbacks
          child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                // 1. The Shadow Layer (Crucial Fix: MUST have a solid color to cast a circular shadow, avoiding square bounding box bugs)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // Solid color prevents rectangular shadow bleeding
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4 * value),
                        blurRadius: 10 * value,
                        spreadRadius: 3 * value,
                      )
                    ],
                  ),
                ),
                // 2. The Image Layer (Explicitly Clipped)
                ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: image,
                        fit: BoxFit.cover,
                      ),
                      // Darken Filter when unselected
                      Container(
                        color: Colors.black.withValues(alpha: 0.4 * (1.0 - value)),
                      ),
                    ],
                  ),
                ),
                // 3. Border Layer (Drawn over the clipped image)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : (isDark ? Colors.white24 : Colors.black12),
                      width: 1 + (2 * value), // 1 to 3
                    ),
                  ),
                ),
                // 4. Arrow Icon (Only if selected)
                if (value > 0)
                  Center(
                    child: Opacity(
                      opacity: value,
                      child: Icon(
                        isLeft ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                        color: Colors.white,
                        size: 28,
                        shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        ), // Close AspectRatio
      ),
    );
  }
}
