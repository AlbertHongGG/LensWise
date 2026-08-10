import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';

class ComparisonResultPage extends StatefulWidget {
  final ComparisonResultArgs args;
  
  const ComparisonResultPage({
    super.key,
    required this.args,
  });

  @override
  State<ComparisonResultPage> createState() => _ComparisonResultPageState();
}

class _ComparisonResultPageState extends State<ComparisonResultPage> {
  int _leftIndex = 0;
  int _rightIndex = 1;

  int get _imageCount {
    if (widget.args.rawImages != null) return widget.args.rawImages!.length;
    if (widget.args.imagePath != null) return widget.args.imagePath!.split(',').length;
    return 0;
  }

  ImageProvider _getImageProvider(int index) {
    if (widget.args.rawImages != null) {
      if (index >= widget.args.rawImages!.length) return MemoryImage(widget.args.rawImages!.last);
      return MemoryImage(widget.args.rawImages![index]);
    }
    final paths = widget.args.imagePath!.split(',');
    if (index >= paths.length) return FileImage(File(paths.last)); // Fallback for old records with only 1 image
    return FileImage(File(paths[index]));
  }

  void _onAvatarTapped(int index) {
    if (index == _leftIndex || index == _rightIndex) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Target Image Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: DecorationImage(
                    image: _getImageProvider(index),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 2)
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '請選擇要替換的對手',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildReplaceButton('替換左側', Icons.keyboard_double_arrow_left, _leftIndex, () {
                    setState(() => _leftIndex = index);
                    Navigator.pop(context);
                  }),
                  const SizedBox(width: 16),
                  _buildReplaceButton('替換右側', Icons.keyboard_double_arrow_right, _rightIndex, () {
                    setState(() => _rightIndex = index);
                    Navigator.pop(context);
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplaceButton(String label, IconData icon, int targetIndex, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            image: DecorationImage(
              image: _getImageProvider(targetIndex),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = widget.args.result;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: const SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildHeroSection()),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(child: _buildSummaryCard(result, isDark)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32).copyWith(bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildComparisonRow(result.comparisonPoints[index], isDark),
                      childCount: result.comparisonPoints.length,
                    ),
                  ),
                ),
              ],
            ),
            if (_imageCount > 2)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: _buildFloatingRoster(isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingRoster(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 76,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.white, width: 1.5),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_imageCount, (index) {
                      final isSelected = index == _leftIndex || index == _rightIndex;
                      return GestureDetector(
                        onTap: () => _onAvatarTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: index == _imageCount - 1 ? 0 : 12),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : Colors.black12),
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)]
                                : [],
                            image: DecorationImage(
                              image: _getImageProvider(index),
                              fit: BoxFit.cover,
                              colorFilter: isSelected ? null : ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                            ),
                          ),
                          child: isSelected
                              ? Center(child: Icon(index == _leftIndex ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right, color: Colors.white, size: 28, shadows: const [Shadow(color: Colors.black, blurRadius: 4)]))
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    if (_imageCount == 0) return const SizedBox.shrink();

    Widget leftWidget = Image(image: _getImageProvider(_leftIndex), fit: BoxFit.cover, height: 220);
    Widget rightWidget = Image(image: _getImageProvider(_rightIndex), fit: BoxFit.cover, height: 220);

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
    String leftVal = 'N/A';
    String rightVal = 'N/A';

    if (_leftIndex < point.values.length) leftVal = point.values[_leftIndex];
    if (_rightIndex < point.values.length) rightVal = point.values[_rightIndex];

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
                  leftVal,
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
                  rightVal,
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
