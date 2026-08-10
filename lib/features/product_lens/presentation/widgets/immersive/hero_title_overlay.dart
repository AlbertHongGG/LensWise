import 'package:flutter/material.dart';

class HeroTitleOverlay extends StatelessWidget {
  final String productName;
  final String originalName;
  final String brand;
  final String origin;

  const HeroTitleOverlay({
    super.key,
    required this.productName,
    required this.originalName,
    required this.brand,
    required this.origin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand & Origin Tag
        if (brand.isNotEmpty || origin.isNotEmpty)
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
              '${brand.isEmpty ? "未知品牌" : brand} ${origin.isNotEmpty ? "· $origin" : ""}'.toUpperCase(),
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
              productName,
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
        if (originalName.isNotEmpty && originalName != productName)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  originalName,
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
    );
  }
}
