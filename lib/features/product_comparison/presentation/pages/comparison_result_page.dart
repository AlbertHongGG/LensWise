import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_hero_section.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_point_card.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_contenders_drawer.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_roster_bar.dart';

class ComparisonResultPage extends StatefulWidget {
  final ComparisonResultArgs args;
  
  const ComparisonResultPage({
    super.key,
    required this.args,
  });

  @override
  State<ComparisonResultPage> createState() => _ComparisonResultPageState();
}

enum DrawerState { none, aiVerdict, contenders }

class _ComparisonResultPageState extends State<ComparisonResultPage> {
  int _leftIndex = 0;
  int _rightIndex = 1;
  DrawerState _drawerState = DrawerState.none;

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
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // 1. Core Visual: Hero VS Section (1v1 Comparison)
                SliverToBoxAdapter(
                  child: ComparisonHeroSection(
                    result: result,
                    leftIndex: _leftIndex,
                    rightIndex: _rightIndex,
                    imageProviderFactory: _getImageProvider,
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // 3. Detail Level: Comparison Points
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32).copyWith(bottom: 120), // Padding for Bottom Roster Bar
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ComparisonPointCard(
                        point: result.comparisonPoints[index],
                        leftIndex: _leftIndex,
                        rightIndex: _rightIndex,
                        isDark: isDark,
                      ),
                      childCount: result.comparisonPoints.length,
                    ),
                  ),
                ),
              ],
            ),
            
            // Bottom Roster Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ComparisonRosterBar(
                itemCount: result.products.length,
                leftIndex: _leftIndex,
                rightIndex: _rightIndex,
                imageProviderFactory: _getImageProvider,
                onProductTapped: _onAvatarTapped,
                isDark: isDark,
              ),
            ),

            // Floating Action Area (Top Right)
            Positioned(
              top: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _drawerState == DrawerState.none ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'ai_verdict',
                      mini: true,
                      onPressed: () => setState(() => _drawerState = DrawerState.aiVerdict),
                      backgroundColor: isDark ? Colors.white24 : Colors.black87,
                      foregroundColor: isDark ? Colors.white : Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.auto_awesome),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'contenders',
                      mini: true,
                      onPressed: () => setState(() => _drawerState = DrawerState.contenders),
                      backgroundColor: isDark ? Colors.white24 : Colors.black87,
                      foregroundColor: isDark ? Colors.white : Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.view_carousel_outlined),
                    ),
                  ],
                ),
              ),
            ),
            
            // Unified Bottom Drawer
            if (_drawerState != DrawerState.none)
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= 0.05) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _drawerState != DrawerState.none) {
                        setState(() => _drawerState = DrawerState.none);
                      }
                    });
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.0,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: _drawerState == DrawerState.aiVerdict
                        ? _buildAiVerdictContent(context, scrollController, result, isDark)
                        : _buildContendersContent(context, scrollController, result, isDark),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiVerdictContent(BuildContext context, ScrollController scrollController, ComparisonResult result, bool isDark) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        // Drag handle area
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black26,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'AI 推薦總結',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                result.summary,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.8,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContendersContent(BuildContext context, ScrollController scrollController, ComparisonResult result, bool isDark) {
    return ComparisonContendersDrawer(
      result: result,
      leftIndex: _leftIndex,
      rightIndex: _rightIndex,
      imageProviderFactory: _getImageProvider,
      onProductTapped: _onAvatarTapped,
      scrollController: scrollController,
      isDark: isDark,
    );
  }

}
