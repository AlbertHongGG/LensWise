import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lens_wise/features/home/presentation/controllers/gallery_state_controller.dart';
import 'package:lens_wise/features/home/presentation/widgets/draggable_date_scrollbar.dart';

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
        _completeSelection();
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withValues(alpha: 0.8),
          height: MediaQuery.of(context).size.height * 0.88,
          child: Column(
            children: [
              // Top drag handle & Actions
              _buildHeader(),
              
              // Gallery Content
              Expanded(
                child: state.hasPermission == false
                    ? const Center(child: Text('無相簿存取權限', style: TextStyle(color: Colors.white)))
                    : state.allAssets.isEmpty && state.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
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

  Widget _buildHeader() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          if (widget.isMultiSelect)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _selectedAssets.isNotEmpty ? _completeSelection : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedAssets.isNotEmpty ? Colors.blueAccent : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '完成 (${_selectedAssets.length}/${widget.maxItems})',
                    style: TextStyle(
                      color: _selectedAssets.isNotEmpty ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent(GalleryState state) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: state.groupKeys.map((key) {
        final assets = state.groupedAssets[key]!;
        return SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(title: key),
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
                                border: Border.all(color: Colors.blueAccent, width: 3),
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
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(250, 250)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.white.withValues(alpha: 0.05));
      },
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _StickyHeaderDelegate({required this.title});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8), // solid enough to block underlying images
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}
