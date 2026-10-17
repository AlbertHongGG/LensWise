import 'package:flutter/material.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/utils/session_image_resolver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_hero_section.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_unified_board.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_contenders_drawer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lens_wise/core/utils/markdown_utils.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_roster_bar.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/comparison_chat_adapter.dart';
import 'package:lens_wise/core/widgets/glass_action_button.dart';

class ComparisonResultPage extends ConsumerStatefulWidget {
  final ProductComparisonRecord record;
  final List<AppImageEntity>? memoryImages;
  
  const ComparisonResultPage({
    super.key,
    required this.record,
    this.memoryImages,
  });

  @override
  ConsumerState<ComparisonResultPage> createState() => _ComparisonResultPageState();
}

typedef ProductComparisonRecordPage = ComparisonResultPage;

class _ComparisonResultPageState extends ConsumerState<ComparisonResultPage> {
  int _leftIndex = 0;
  int _rightIndex = 1;
  late final ProductComparisonScannerController _controller;
  late final SessionImageResolver _imageResolver;

  bool get isLiveSession => widget.memoryImages != null;

  @override
  void initState() {
    super.initState();
    _imageResolver = SessionImageResolver(
      memoryImages: widget.memoryImages,
      imagePaths: widget.record.imagePaths,
    );
    if (isLiveSession) {
      _controller = ref.read(productComparisonScannerControllerProvider.notifier);
    }
  }

  @override
  void dispose() {
    if (isLiveSession) {
      Future.microtask(() => _controller.reset());
    }
    super.dispose();
  }

  ImageProvider _getImageProvider(int index) => _imageResolver.resolve(index);

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

  void _showAiVerdictSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) => GestureDetector(
              onTap: () {}, // Prevent taps on content from closing the sheet
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: isLiveSession
                    ? Consumer(
                        builder: (context, ref, _) {
                          final currentResult = ref.watch(productComparisonScannerControllerProvider.select((s) => s.parsingResult ?? widget.record));
                          return _buildAiVerdictContent(
                            context,
                            scrollController,
                            currentResult,
                            isDark,
                          );
                        },
                      )
                    : _buildAiVerdictContent(
                        context,
                        scrollController,
                        widget.record,
                        isDark,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContendersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) => GestureDetector(
              onTap: () {}, // Prevent taps on content from closing the sheet
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: isLiveSession
                    ? Consumer(
                        builder: (context, ref, _) {
                          final currentResult = ref.watch(productComparisonScannerControllerProvider.select((s) => s.parsingResult ?? widget.record));
                          return _buildContendersContent(
                            context,
                            scrollController,
                            currentResult,
                            isDark,
                          );
                        },
                      )
                    : _buildContendersContent(
                        context,
                        scrollController,
                        widget.record,
                        isDark,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeResult = isLiveSession
        ? ref.watch(productComparisonScannerControllerProvider.select((s) => s.parsingResult ?? widget.record))
        : widget.record;
    final isStreaming = isLiveSession &&
        ref.watch(productComparisonScannerControllerProvider.select((s) => s.status == ProductComparisonStatus.streaming));
    final productCount = _imageResolver.hasImages
        ? _imageResolver.count
        : activeResult.products.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // 1 & 2. Hero Section and Integrated Console (Stacked for Z-order)
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Bottom Layer: The Integrated Console (tucked 24px behind the hero)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 220 - 24,
                          bottom: 120, // Padding for Bottom Roster Bar
                        ),
                        child: ComparisonUnifiedBoard(
                          result: activeResult,
                          leftIndex: _leftIndex,
                          rightIndex: _rightIndex,
                          isDark: isDark,
                          isStreaming: isStreaming,
                          isLiveSession: isLiveSession,
                        ),
                      ),
                      
                      // Top Layer: Hero VS Section (Pressing down on the board)
                      ComparisonHeroSection(
                        result: activeResult,
                        leftIndex: _leftIndex,
                        rightIndex: _rightIndex,
                        imageProviderFactory: _getImageProvider,
                        isLiveSession: isLiveSession,
                      ),
                    ],
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
                itemCount: productCount,
                leftIndex: _leftIndex,
                rightIndex: _rightIndex,
                imageProviderFactory: _getImageProvider,
                onProductTapped: _onAvatarTapped,
                isDark: isDark,
              ),
            ),

            // Floating Action Area (Top Right)
            Positioned(
              top: 24, // Slightly lower for better safe area breathing room
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassActionButton(
                    icon: Icons.auto_awesome,
                    onPressed: () => showComparisonChat(
                      context,
                      isLiveSession
                          ? (ref.read(productComparisonScannerControllerProvider).parsingResult ?? widget.record)
                          : widget.record,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassActionButton(
                    icon: Icons.summarize_outlined,
                    onPressed: _showAiVerdictSheet,
                  ),
                  const SizedBox(height: 12),
                  GlassActionButton(
                    icon: Icons.view_carousel_outlined,
                    onPressed: _showContendersSheet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiVerdictContent(BuildContext context, ScrollController scrollController, ProductComparisonRecord result, bool isDark) {
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
              if (result.summary.trim().isEmpty)
                const Column(
                  children: [
                    StreamingSkeleton(width: double.infinity, height: 20, margin: EdgeInsets.only(bottom: 12)),
                    StreamingSkeleton(width: double.infinity, height: 20, margin: EdgeInsets.only(bottom: 12)),
                    StreamingSkeleton(width: 200, height: 20),
                  ],
                )
              else
                MarkdownBody(
                  data: MarkdownUtils.formatAiMarkdown(result.summary),
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                    h2: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                      height: 1.5,
                      letterSpacing: 0.5,
                    ),
                    h3: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                    p: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF2D3748),
                      height: 1.75,
                      letterSpacing: 0.3,
                    ),
                    listBullet: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    listIndent: 20,
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    blockquote: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.6,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05),
                      border: const Border(left: BorderSide(color: AppColors.primary, width: 3.5)),
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                    ),
                    blockquotePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    blockSpacing: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContendersContent(BuildContext context, ScrollController scrollController, ProductComparisonRecord result, bool isDark) {
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
