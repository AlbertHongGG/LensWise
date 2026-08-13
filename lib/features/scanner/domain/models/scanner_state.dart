import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'scanner_mode_config.dart';

part 'scanner_state.freezed.dart';

enum CameraActionState { idle, capturing, pickingGallery, analyzing }

@freezed
abstract class ScannerState with _$ScannerState {
  const factory ScannerState({
    @Default(ScannerMode.product) ScannerMode currentMode,
    @Default([]) List<AppImageEntity> capturedImages,
    @Default(CameraActionState.idle) CameraActionState actionState,
  }) = _ScannerState;

  const ScannerState._();

  ScannerModeConfig get config => ScannerModeConfig.configurations[currentMode]!;
  
  bool get hasReachedMinShots => capturedImages.length >= config.minShotsRequired;
  bool get hasReachedMaxShots => config.maxShotsAllowed != null && capturedImages.length >= config.maxShotsAllowed!;
  bool get isLocked => actionState != CameraActionState.idle;
}
