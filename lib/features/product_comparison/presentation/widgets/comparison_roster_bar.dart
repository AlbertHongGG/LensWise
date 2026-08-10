import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_avatar.dart';

class ComparisonRosterBar extends StatelessWidget {
  final int imageCount;
  final int leftIndex;
  final int rightIndex;
  final bool isDark;
  final ImageProvider Function(int index) imageProviderFactory;
  final ValueChanged<int> onAvatarTapped;

  const ComparisonRosterBar({
    super.key,
    required this.imageCount,
    required this.leftIndex,
    required this.rightIndex,
    required this.isDark,
    required this.imageProviderFactory,
    required this.onAvatarTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 76,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withValues(alpha: 0.4) 
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.white, 
                    width: 1.5,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // Critical for responsive architecture: force children to expand vertically to the available space
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(imageCount, (index) {
                      final isSelected = index == leftIndex || index == rightIndex;
                      final isLeft = index == leftIndex;
                      
                      return ComparisonAvatar(
                        image: imageProviderFactory(index),
                        isSelected: isSelected,
                        isLeft: isLeft,
                        isDark: isDark,
                        onTap: () => onAvatarTapped(index),
                        margin: EdgeInsets.only(
                          right: index == imageCount - 1 ? 0 : 12,
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
    );
  }
}
