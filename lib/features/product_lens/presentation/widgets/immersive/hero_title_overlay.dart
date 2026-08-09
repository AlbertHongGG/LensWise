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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand & Origin Tag
          if (brand.isNotEmpty || origin.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${brand.isEmpty ? "未知品牌" : brand} ${origin.isNotEmpty ? "· $origin" : ""}'.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          
          // Translated Product Name
          Text(
            productName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          
          // Original Name (Elegant Subtitle)
          if (originalName.isNotEmpty && originalName != productName)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                originalName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
