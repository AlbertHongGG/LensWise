import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/scanner/domain/interfaces/i_gallery_service.dart';
import 'package:lens_wise/core/di/hardware_providers.dart';
import 'package:lens_wise/features/scanner/domain/models/gallery_asset.dart';
import 'package:intl/intl.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';

class GalleryState {
  final List<GalleryAsset> allAssets;
  final Map<String, List<GalleryAsset>> groupedAssets;
  final List<String> groupKeys; // To preserve order
  final bool hasPermission;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;

  GalleryState({
    required this.allAssets,
    required this.groupedAssets,
    required this.groupKeys,
    required this.hasPermission,
    required this.isLoading,
    required this.hasMore,
    this.errorMessage,
  });

  GalleryState copyWith({
    List<GalleryAsset>? allAssets,
    Map<String, List<GalleryAsset>>? groupedAssets,
    List<String>? groupKeys,
    bool? hasPermission,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
  }) {
    return GalleryState(
      allAssets: allAssets ?? this.allAssets,
      groupedAssets: groupedAssets ?? this.groupedAssets,
      groupKeys: groupKeys ?? this.groupKeys,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

class GalleryStateController extends Notifier<GalleryState> with WidgetsBindingObserver {
  late final IGalleryService _service;
  int _currentPage = 0;
  final int _pageSize = 100;

  @override
  GalleryState build() {
    _service = ref.watch(galleryServiceProvider);
    
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    
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

    state = state.copyWith(hasPermission: true);
    await _loadNextPage();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    try {
      final assets = await _service.getRecentAssets(_currentPage, _pageSize);
      
      if (assets.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      final newAllAssets = [...state.allAssets, ...assets];
      final newGroupedAssets = Map<String, List<GalleryAsset>>.from(state.groupedAssets);
      
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
      state = state.copyWith(isLoading: false, errorMessage: '無法讀取相簿');
      ref.read(notificationProvider.notifier).showError('無法讀取相簿：$e');
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _silentRefresh();
    }
  }

  Future<void> _silentRefresh() async {
    if (!state.hasPermission) return;
    try {
      final assets = await _service.getRecentAssets(0, _pageSize);
      if (assets.isEmpty) return;

      final currentFirstId = state.allAssets.isNotEmpty ? state.allAssets.first.id : null;
      if (assets.first.id == currentFirstId) {
        return; // No new photos
      }

      int newCount = 0;
      for (int i = 0; i < assets.length; i++) {
        if (assets[i].id == currentFirstId) {
          break;
        }
        newCount++;
      }

      List<GalleryAsset> newAllAssets;
      if (newCount < assets.length || currentFirstId == null) {
        final newPhotos = assets.sublist(0, newCount);
        newAllAssets = [...newPhotos, ...state.allAssets];
      } else {
        newAllAssets = assets;
        _currentPage = 1; 
      }

      final newGroupedAssets = <String, List<GalleryAsset>>{};
      for (final asset in newAllAssets) {
        final date = asset.createDateTime;
        final monthFormatter = DateFormat('M月 yyyy');
        final key = monthFormatter.format(date);
        
        if (!newGroupedAssets.containsKey(key)) {
          newGroupedAssets[key] = [];
        }
        newGroupedAssets[key]!.add(asset);
      }

      state = state.copyWith(
        allAssets: newAllAssets,
        groupedAssets: newGroupedAssets,
        groupKeys: newGroupedAssets.keys.toList(),
      );
    } catch (e) {
      // Ignore errors on silent refresh
    }
  }
}

final galleryStateProvider = NotifierProvider<GalleryStateController, GalleryState>(() {
  return GalleryStateController();
});
