import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_text.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';

class VerdictFloatingCard extends ConsumerWidget {
  final String? initialSummary;
  final String? summary;
  final bool isStreaming;

  const VerdictFloatingCard({
    super.key,
    this.initialSummary,
    this.summary,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fine-grained selector: Only rebuilds when summary text actually changes!
    final effectiveSummary = ref.watch(productLensControllerProvider.select((state) {
      final resSummary = state.result?.summary;
      if (resSummary != null && resSummary.isNotEmpty) {
        return resSummary;
      }
      return summary ?? initialSummary ?? '';
    }));

    if (effectiveSummary.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E1E).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                StreamingSkeleton(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                SizedBox(width: 12),
                StreamingSkeleton(width: 80, height: 18),
              ],
            ),
            const SizedBox(height: 16),
            const StreamingSkeleton(width: double.infinity, height: 14),
            const SizedBox(height: 10),
            const StreamingSkeleton(width: 220, height: 14),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '商品簡介',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamingText(
            text: effectiveSummary,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
