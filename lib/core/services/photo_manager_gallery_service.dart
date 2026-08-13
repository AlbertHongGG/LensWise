import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:lens_wise/features/scanner/domain/interfaces/i_gallery_service.dart';
import 'package:lens_wise/features/scanner/domain/models/gallery_asset.dart';

class PhotoManagerGalleryAsset implements GalleryAsset {
  final AssetEntity entity;

  PhotoManagerGalleryAsset(this.entity);

  @override
  String get id => entity.id;

  @override
  DateTime get createDateTime => entity.createDateTime;

  @override
  Future<Uint8List?> get originBytes => entity.originBytes;

  @override
  ImageProvider getThumbnailProvider({int size = 250}) {
    return AssetEntityImageProvider(
      entity,
      isOriginal: false,
      thumbnailSize: ThumbnailSize.square(size),
    );
  }
}

class PhotoManagerGalleryService implements IGalleryService {
  /// Requests permission to access the gallery.
  @override
  Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );
    print('PhotoManager PermissionState: $ps');
    return ps.isAuth;
  }

  @override
  Future<List<GalleryAsset>> getRecentAssets(int page, int size) async {
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
      ),
    );
    if (albums.isEmpty) return [];

    final album = albums.first;
    final assets = await album.getAssetListPaged(page: page, size: size);
    
    return assets.map((e) => PhotoManagerGalleryAsset(e)).toList();
  }
}
