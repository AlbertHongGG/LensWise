import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';

class ComparisonResultPage extends ConsumerStatefulWidget {
  final ComparisonResultArgs args;
  
  const ComparisonResultPage({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<ComparisonResultPage> createState() => _ComparisonResultPageState();
}

class _ComparisonResultPageState extends ConsumerState<ComparisonResultPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = widget.args.result;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildSummaryCard(result, isDark)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildComparisonRow(result.comparisonPoints[index], isDark),
                  childCount: result.comparisonPoints.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    Widget leftWidget = const SizedBox();
    Widget rightWidget = const SizedBox();

    if (widget.args.rawImages != null && widget.args.rawImages!.length >= 2) {
      leftWidget = Image.memory(widget.args.rawImages![0], fit: BoxFit.cover, height: 220);
      rightWidget = Image.memory(widget.args.rawImages![1], fit: BoxFit.cover, height: 220);
    } else if (widget.args.imagePath != null) {
      final paths = widget.args.imagePath!.split(',');
      if (paths.length >= 2) {
        leftWidget = Image.file(File(paths[0]), fit: BoxFit.cover, height: 220);
        rightWidget = Image.file(File(paths[1]), fit: BoxFit.cover, height: 220);
      } else {
        // Fallback if only 1 image saved
        leftWidget = Image.file(File(paths[0]), fit: BoxFit.cover, height: 220);
        rightWidget = Image.file(File(paths[0]), fit: BoxFit.cover, height: 220);
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                  child: leftWidget,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                  child: rightWidget,
                ),
              ),
            ],
          ),
          // VS Badge (breathing glow)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ComparisonResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                '關鍵差異',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.summary,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(ComparisonPoint point, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Aspect Title (Balance Pivot)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              point.aspect,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Left vs Right values
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  point.leftValue,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 32), // Pivot gap
              Expanded(
                child: Text(
                  point.rightValue,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
        ],
      ),
    );
  }
}
