import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';

class ProductResultCard extends StatelessWidget {
  final ProductAnalysisResult result;
  final VoidCallback onClose;

  const ProductResultCard({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = result.status != 'success';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.85),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (isError)
                _buildErrorState(context, theme)
              else
                _buildSuccessState(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          result.message ?? 'Unknown Error',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onClose,
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, ThemeData theme) {
    final data = result.data;
    if (data == null) return const SizedBox.shrink();

    final productName = data.productName.isNotEmpty
        ? data.productName
        : 'Unknown Product';
    final brand = data.brand;
    final summary = data.summary;
    final ingredients = data.ingredients;
    final allergens = data.allergens;

    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (brand.isNotEmpty)
                      Text(
                        brand.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      productName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: onClose,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (allergens.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Allergens',
              Icons.warning_amber_rounded,
              theme.colorScheme.error,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allergens
                  .map((e) => _buildChip(context, e, true))
                  .toList(),
            ),
          ],
          if (ingredients.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle(
              context,
              'Ingredients',
              Icons.science_outlined,
              theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredients
                  .map((e) => _buildChip(context, e, false))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, bool isAlert) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAlert
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert
              ? theme.colorScheme.error.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isAlert
              ? theme.colorScheme.onErrorContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
