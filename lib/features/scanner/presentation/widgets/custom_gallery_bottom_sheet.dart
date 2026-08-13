import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/gallery_state_controller.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/draggable_date_scrollbar.dart';

import 'package:lens_wise/core/widgets/pickers/picker_dialog_shell.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

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
  final ValueNotifier<List<AssetEntity>> _selectedAssetsNotifier = ValueNotifier([]);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _selectedAssetsNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(galleryStateProvider.notifier).loadMore();
    }
  }

  Future<void> _completeSelection() async {
    final selected = _selectedAssetsNotifier.value;
    if (selected.isEmpty) return; // Prevent confirming with no selection
    final List<AppImageEntity> imagesList = [];
    for (final asset in selected) {
      final bytes = await asset.originBytes;
      if (bytes != null) {
        imagesList.add(AppImageEntity(bytes: bytes, source: ImageSourceType.gallery));
      }
    }
    if (mounted) {
      Navigator.of(context).pop(imagesList);
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
                        ValueListenableBuilder<List<AssetEntity>>(
                          valueListenable: _selectedAssetsNotifier,
                          builder: (context, selected, child) {
                            return IconButton(
                              onPressed: selected.isEmpty ? null : _completeSelection,
                              icon: const Icon(Icons.check_circle_rounded),
                              color: theme.primaryColor,
                              iconSize: 28,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            );
                          },
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
                    return GalleryItemWidget(
                      asset: asset,
                      selectedAssetsNotifier: _selectedAssetsNotifier,
                      isMultiSelect: widget.isMultiSelect,
                      maxItems: widget.maxItems,
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

class GalleryItemWidget extends StatelessWidget {
  final AssetEntity asset;
  final ValueNotifier<List<AssetEntity>> selectedAssetsNotifier;
  final bool isMultiSelect;
  final int maxItems;

  const GalleryItemWidget({
    super.key,
    required this.asset,
    required this.selectedAssetsNotifier,
    required this.isMultiSelect,
    required this.maxItems,
  });

  void _toggleSelection() {
    final currentList = List<AssetEntity>.from(selectedAssetsNotifier.value);
    
    if (!isMultiSelect) {
      selectedAssetsNotifier.value = [asset];
    } else {
      if (currentList.contains(asset)) {
        currentList.remove(asset);
        selectedAssetsNotifier.value = currentList;
      } else {
        if (currentList.length < maxItems) {
          currentList.add(asset);
          selectedAssetsNotifier.value = currentList;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _toggleSelection,
      child: ValueListenableBuilder<List<AssetEntity>>(
        valueListenable: selectedAssetsNotifier,
        builder: (context, selected, child) {
          final isSelected = selected.contains(asset);
          
          return Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: AssetEntityImageProvider(
                  asset,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize.square(250),
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
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
          );
        },
      ),
    );
  }
}
