import 'package:lens_wise/features/scanner/domain/models/gallery_asset.dart';

abstract class IGalleryService {
  /// Requests permission to access the gallery.
  Future<bool> requestPermission();

  /// Gets a paginated list of assets from the default (Recent/All) album.
  Future<List<GalleryAsset>> getRecentAssets(int page, int size);
}
