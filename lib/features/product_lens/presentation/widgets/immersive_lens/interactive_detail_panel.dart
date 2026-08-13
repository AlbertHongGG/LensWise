import 'package:flutter/material.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/glass_action_button.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/product_chat_adapter.dart';

class InteractiveDetailPanel extends StatelessWidget {
  final ProductLensRecord record;

  const InteractiveDetailPanel({super.key, required this.record});

  void _showIngredientsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetailSheet(
        title: '成分與過敏原',
        icon: Icons.science_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record.allergenAlerts.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...record.allergenAlerts.map(
                    (a) => _buildBadge(ctx, a, isAlert: true),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (record.ingredients.isNotEmpty) ...[
              const Text(
                '主要成分',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                record.ingredients.join(', '),
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
            ] else
              const Text(
                '無詳細成分標示',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  void _showProsConsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetailSheet(
        title: '適合對象分析',
        icon: Icons.people_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProsConsBlock(
              ctx,
              '推薦情境',
              Icons.check_circle_outline,
              Colors.green,
              record.whenRecommended,
            ),
            const SizedBox(height: 24),
            _buildProsConsBlock(
              ctx,
              '不推薦情境',
              Icons.cancel_outlined,
              Colors.redAccent,
              record.whenNotRecommended,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProsConsBlock(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text(
            '無特別註明',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: CircleAvatar(radius: 3, backgroundColor: color),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context,
    String text, {
    required bool isAlert,
  }) {
    final color = isAlert ? Colors.redAccent : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAlert) ...[
            Icon(Icons.warning_amber_rounded, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasIngredients =
        record.ingredients.isNotEmpty || record.allergenAlerts.isNotEmpty;
    final hasProsCons =
        record.whenRecommended.isNotEmpty ||
        record.whenNotRecommended.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIngredients) ...[
          GlassActionButton(
            icon: Icons.science_outlined,
            onPressed: () => _showIngredientsSheet(context),
          ),
          const SizedBox(width: 12),
        ],
        if (hasProsCons) ...[
          GlassActionButton(
            icon: Icons.people_outline,
            onPressed: () => _showProsConsSheet(context),
          ),
          const SizedBox(width: 12),
        ],
        GlassActionButton(
          icon: Icons.auto_awesome,
          onPressed: () => showProductChat(context, record),
        ),
      ],
    );
  }
}


class _DetailSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSheet({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(icon, size: 28, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
