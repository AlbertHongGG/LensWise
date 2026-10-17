import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/glass_action_button.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/product_chat_adapter.dart';

class InteractiveDetailPanel extends ConsumerWidget {
  final ProductLensRecord? initialRecord;
  final bool isLiveSession;

  const InteractiveDetailPanel({
    super.key,
    ProductLensRecord? initialRecord,
    ProductLensRecord? record,
    this.isLiveSession = false,
  }) : initialRecord = initialRecord ?? record;

  void _showIngredientsSheet(BuildContext context, ProductLensRecord record) {
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

  void _showProsConsSheet(BuildContext context, ProductLensRecord record) {
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

  Widget _buildBadge(BuildContext context, String text, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAlert
            ? Colors.red.withValues(alpha: 0.1)
            : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAlert
              ? Colors.red.withValues(alpha: 0.3)
              : Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isAlert ? Colors.red : Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained selector: Only rebuilds when boolean availability flags change in live mode!
    final flags = isLiveSession
        ? ref.watch(productLensControllerProvider.select((state) {
            final rec = state.result ?? initialRecord;
            if (rec == null) return (hasIngredients: false, hasProsCons: false);
            return (
              hasIngredients: rec.ingredients.isNotEmpty || rec.allergenAlerts.isNotEmpty,
              hasProsCons: rec.whenRecommended.isNotEmpty || rec.whenNotRecommended.isNotEmpty,
            );
          }))
        : (
            hasIngredients: (initialRecord?.ingredients.isNotEmpty ?? false) ||
                (initialRecord?.allergenAlerts.isNotEmpty ?? false),
            hasProsCons: (initialRecord?.whenRecommended.isNotEmpty ?? false) ||
                (initialRecord?.whenNotRecommended.isNotEmpty ?? false),
          );

    ProductLensRecord getActiveRecord() {
      if (!isLiveSession) {
        return initialRecord ?? ProductLensRecord.empty();
      }
      return ref.read(productLensControllerProvider).result ?? initialRecord ?? ProductLensRecord.empty();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flags.hasIngredients) ...[
          GlassActionButton(
            icon: Icons.science_outlined,
            onPressed: () => _showIngredientsSheet(context, getActiveRecord()),
          ),
          const SizedBox(width: 12),
        ],
        if (flags.hasProsCons) ...[
          GlassActionButton(
            icon: Icons.people_outline,
            onPressed: () => _showProsConsSheet(context, getActiveRecord()),
          ),
          const SizedBox(width: 12),
        ],
        GlassActionButton(
          icon: Icons.auto_awesome,
          onPressed: () => showProductChat(context, getActiveRecord()),
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
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
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
