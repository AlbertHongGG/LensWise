import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';

class ComparisonRosterBar extends StatelessWidget {
  final int itemCount;
  final int leftIndex;
  final int rightIndex;
  final ImageProvider Function(int) imageProviderFactory;
  final void Function(int) onProductTapped;
  final bool isDark;

  const ComparisonRosterBar({
    super.key,
    required this.itemCount,
    required this.leftIndex,
    required this.rightIndex,
    required this.imageProviderFactory,
    required this.onProductTapped,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 2) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 64,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(itemCount, (index) {
                        final isSelected = index == leftIndex || index == rightIndex;
                        final isLeft = index == leftIndex;

                        return GestureDetector(
                          onTap: () => onProductTapped(index),
                          child: Container(
                            width: 54,
                            height: 54,
                            margin: EdgeInsets.only(right: index == itemCount - 1 ? 0 : 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                              ],
                              image: DecorationImage(
                                image: imageProviderFactory(index),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: isSelected
                                ? Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: Icon(
                                        isLeft ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_right,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
