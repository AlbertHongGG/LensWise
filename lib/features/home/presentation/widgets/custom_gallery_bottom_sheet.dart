import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lens_wise/features/home/presentation/controllers/gallery_state_controller.dart';
import 'package:lens_wise/features/home/presentation/widgets/draggable_date_scrollbar.dart';

import 'package:lens_wise/core/widgets/pickers/picker_dialog_shell.dart';

class CustomGalleryBottomSheet extends ConsumerStatefulWidget {
  final bool isMultiSelect;
  final int maxItems;

  const CustomGalleryBottomSheet({
    super.key,
    this.isMultiSelect = false,
    this.maxItems = 2,
  });

  @override
  ConsumerState<CustomGalleryBottomSheet> createState() => _CustomGalleryBottomSheetState();
}

class _CustomGalleryBottomSheetState extends ConsumerState<CustomGalleryBottomSheet> {
  final List<AssetEntity> _selectedAssets = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(galleryStateProvider.notifier).loadMore();
    }
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (!widget.isMultiSelect) {
        _selectedAssets.clear();
        _selectedAssets.add(asset);
      } else {
        if (_selectedAssets.contains(asset)) {
          _selectedAssets.remove(asset);
        } else {
          if (_selectedAssets.length < widget.maxItems) {
            _selectedAssets.add(asset);
          }
        }
      }
    });
  }

  Future<void> _completeSelection() async {
    if (_selectedAssets.isEmpty) return; // Prevent confirming with no selection
    final List<Uint8List> bytesList = [];
    for (final asset in _selectedAssets) {
      final bytes = await asset.originBytes;
      if (bytes != null) bytesList.add(bytes);
    }
    if (mounted) {
      Navigator.of(context).pop(bytesList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: Container(
        color: theme.scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height * 0.88,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle and Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    // Drag Handle
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    // Header with Title and Done Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // Placeholder to keep title perfectly centered
                        Text(
                          '選擇照片',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        IconButton(
                          onPressed: _selectedAssets.isEmpty ? null : _completeSelection,
                          icon: const Icon(Icons.check_circle_rounded),
                          color: theme.primaryColor,
                          iconSize: 28,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Gallery Content
              Expanded(
                child: state.hasPermission == false
                    ? const Center(child: Text('無相簿存取權限'))
                    : state.allAssets.isEmpty && state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : DraggableDateScrollbar(
                            controller: _scrollController,
                            groupKeys: state.groupKeys,
                            groupedAssets: state.groupedAssets,
                            child: _buildGalleryContent(state),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryContent(GalleryState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: state.groupKeys.map((key) {
        final assets = state.groupedAssets[key]!;
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                alignment: Alignment.bottomLeft,
                child: Text(
                  key,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final asset = assets[index];
                    final isSelected = _selectedAssets.contains(asset);
                    return GestureDetector(
                      onTap: () => _toggleSelection(asset),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetThumbnail(asset: asset),
                          if (isSelected)
                            Container(
                              color: Colors.black.withValues(alpha: 0.4),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
                            ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.primaryColor, width: 3),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  childCount: assets.length,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  const AssetThumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(250, 250)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05));
      },
    );
  }
}
