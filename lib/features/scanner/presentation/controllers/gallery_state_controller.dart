import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lens_wise/core/utils/photo_manager_service.dart';
import 'package:intl/intl.dart';

class GalleryState {
  final List<AssetEntity> allAssets;
  final Map<String, List<AssetEntity>> groupedAssets;
  final List<String> groupKeys; // To preserve order
  final bool hasPermission;
  final bool isLoading;
  final bool hasMore;

  GalleryState({
    required this.allAssets,
    required this.groupedAssets,
    required this.groupKeys,
    required this.hasPermission,
    required this.isLoading,
    required this.hasMore,
  });

  GalleryState copyWith({
    List<AssetEntity>? allAssets,
    Map<String, List<AssetEntity>>? groupedAssets,
    List<String>? groupKeys,
    bool? hasPermission,
    bool? isLoading,
    bool? hasMore,
  }) {
    return GalleryState(
      allAssets: allAssets ?? this.allAssets,
      groupedAssets: groupedAssets ?? this.groupedAssets,
      groupKeys: groupKeys ?? this.groupKeys,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class GalleryStateController extends Notifier<GalleryState> {
  late final PhotoManagerService _service;
  AssetPathEntity? _currentAlbum;
  int _currentPage = 0;
  final int _pageSize = 100;

  @override
  GalleryState build() {
    _service = ref.watch(photoManagerServiceProvider);
    
    // Auto-init
    Future.microtask(() => initGallery());
    
    return GalleryState(
      allAssets: [],
      groupedAssets: {},
      groupKeys: [],
      hasPermission: false,
      isLoading: false,
      hasMore: true,
    );
  }

  Future<void> initGallery() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    final hasPermission = await _service.requestPermission();
    if (!hasPermission) {
      state = state.copyWith(isLoading: false, hasPermission: false);
      return;
    }

    _currentAlbum = await _service.getRecentAlbum();
    if (_currentAlbum == null) {
      state = state.copyWith(isLoading: false, hasPermission: true, hasMore: false);
      return;
    }

    state = state.copyWith(hasPermission: true);
    await _loadNextPage();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || _currentAlbum == null) return;
    state = state.copyWith(isLoading: true);
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    try {
      final assets = await _service.getAssetsFromAlbum(_currentAlbum!, _currentPage, _pageSize);
      
      if (assets.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      final newAllAssets = [...state.allAssets, ...assets];
      final newGroupedAssets = Map<String, List<AssetEntity>>.from(state.groupedAssets);
      
      for (final asset in assets) {
        final date = asset.createDateTime;
        final monthFormatter = DateFormat('M月 yyyy');
        final key = monthFormatter.format(date);
        
        if (!newGroupedAssets.containsKey(key)) {
          newGroupedAssets[key] = [];
        }
        newGroupedAssets[key]!.add(asset);
      }

      final newGroupKeys = newGroupedAssets.keys.toList();

      _currentPage++;
      state = state.copyWith(
        allAssets: newAllAssets,
        groupedAssets: newGroupedAssets,
        groupKeys: newGroupKeys,
        isLoading: false,
        hasMore: assets.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final galleryStateProvider = NotifierProvider<GalleryStateController, GalleryState>(() {
  return GalleryStateController();
});
