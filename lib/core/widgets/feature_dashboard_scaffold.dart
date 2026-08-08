import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';

class FeatureDashboardScaffold extends StatelessWidget {
  final Widget body;
  final String historyRoutePath;
  final String title;

  const FeatureDashboardScaffold({
    super.key,
    required this.body,
    required this.historyRoutePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ImmersiveScaffold(
      body: Stack(
        children: [
          // Main Body
          Positioned.fill(
            child: body,
          ),
          
          // Top Left Settings Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildFloatingButton(
              context,
              icon: Icons.settings_rounded,
              onTap: () => context.push('/settings'),
            ),
          ),
          
          // Top Right History Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildFloatingButton(
              context,
              icon: Icons.history_rounded,
              onTap: () => context.push(historyRoutePath),
            ),
          ),
          
          // Optional Centered Title (subtle)
          Positioned(
            top: MediaQuery.of(context).padding.top + 28,
            left: 80,
            right: 80,
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        opacity: isDark ? 0.15 : 0.05,
        blur: 10,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black87,
            size: 24,
          ),
        ),
      ),
    );
  }
}
