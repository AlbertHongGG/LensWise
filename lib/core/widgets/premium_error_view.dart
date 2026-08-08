import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';

class PremiumErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onActionPressed;
  final String actionLabel;
  final bool isDark;

  const PremiumErrorView({
    super.key,
    required this.title,
    required this.message,
    required this.onActionPressed,
    this.actionLabel = '返回相機',
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Icon Container
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? Colors.redAccent.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.05)),
                  border: Border.all(
                    color: (isDark ? Colors.redAccent.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.2)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: isDark ? Colors.redAccent : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Translated Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              
              // Action Button
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
