import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const GlassActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.55),
            child: InkWell(
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF111418),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
