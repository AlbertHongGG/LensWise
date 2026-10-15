import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';

class ConfigOptionBottomSheet extends StatelessWidget {
  final String title;
  final List<FieldOption> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const ConfigOptionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<FieldOption> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ConfigOptionBottomSheet(
        title: title,
        options: options,
        selectedValue: selectedValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) {
              final isSelected = option.value.toLowerCase() == selectedValue.toLowerCase();

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                onTap: () {
                  onSelected(option.value);
                  Navigator.pop(context);
                },
                leading: option.icon != null
                    ? Icon(option.icon, color: theme.primaryColor)
                    : null,
                title: Text(
                  option.label,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: option.description != null && option.description!.isNotEmpty
                    ? Text(
                        option.description!,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      )
                    : null,
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
                    : null,
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
