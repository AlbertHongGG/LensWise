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
            curve: Curves.easeOutCubic, // Absolutely smooth mathematical curve, no overshoot clamping
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.85 + (0.15 * value), // 0.85 when unselected, 1.0 when selected
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    // 1. Soft Premium Shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25 * value),
                            blurRadius: 12 * value,
                            spreadRadius: 2 * value,
                            offset: Offset(0, 4 * value),
                          )
                        ],
                      ),
                    ),
                    // 2. Image Layer with Smooth Dimming
                    ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: image,
                            fit: BoxFit.cover,
                          ),
                          // Darken unselected items
                          Container(
                            color: Colors.black.withValues(alpha: 0.45 * (1.0 - value)),
                          ),
                        ],
                      ),
                    ),
                    // 3. Crisp Premium Border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: value),
                          width: 2.0 * value,
                        ),
                      ),
                    ),
                    // 4. Centered Minimalist Icon
                    if (value > 0.0)
                      Center(
                        child: Opacity(
                          opacity: value,
                          child: Icon(
                            isLeft ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                            color: Colors.white,
                            size: 28,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
        ),
        ), // Close AspectRatio
      ),
    );
  }
}
