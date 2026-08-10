import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final photoManagerServiceProvider = Provider<PhotoManagerService>((ref) {
  return PhotoManagerService();
});

class PhotoManagerService {
  /// Requests permission to access the gallery.
  Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );
    print('PhotoManager PermissionState: $ps');
    return ps.isAuth;
  }

  /// Gets the "Recent" or "All" album.
  Future<AssetPathEntity?> getRecentAlbum() async {
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (albums.isNotEmpty) {
      return albums.first;
    }
    return null;
  }

  /// Gets a paginated list of assets from the given album.
  Future<List<AssetEntity>> getAssetsFromAlbum(
      AssetPathEntity album, int page, int size) async {
    return await album.getAssetListPaged(page: page, size: size);
  }
}
