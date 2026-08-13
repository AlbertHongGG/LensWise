import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

import 'package:lens_wise/features/scanner/domain/models/scanner_state.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/scanner_controller.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/scanner_action_button.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/scanner_mode_switcher.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/gallery_picker_button.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/custom_gallery_bottom_sheet.dart';
import 'package:lens_wise/features/scanner/presentation/pages/captured_image_gallery_screen.dart';

class ScannerBottomBar extends ConsumerWidget {
  final CameraState? cameraState;

  const ScannerBottomBar({super.key, required this.cameraState});

  Future<void> _takePicture(BuildContext context, WidgetRef ref) async {
    final state = ref.read(scannerControllerProvider);
    final notifier = ref.read(scannerControllerProvider.notifier);
    
    if (state.isLocked || cameraState == null) return;
    
    notifier.setActionState(CameraActionState.capturing);

    try {
      if (cameraState is PhotoCameraState) {
        final photoState = cameraState as PhotoCameraState;
        final request = await photoState.takePhoto();
        final path = request.when(
          single: (single) => single.file?.path,
          multiple: (multiple) => multiple.fileBySensor.values.first?.path,
        );
        
        if (path != null && context.mounted) {
          final bytes = await File(path).readAsBytes();
          
          if (context.mounted) {
            notifier.onImageCaptured(bytes);
          }
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to take picture: $e');
    } finally {
      if (ref.read(scannerControllerProvider).actionState == CameraActionState.capturing) {
        notifier.setActionState(CameraActionState.idle);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScannerActionButton(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGalleryPickerButton(context, ref),
                _buildShutterButton(context, ref),
                _buildCapturedBadgeButton(context, ref),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ScannerModeSwitcher(),
        ],
      ),
    );
  }

  Widget _buildGalleryPickerButton(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerControllerProvider);
    final locked = state.isLocked;
    final isPicking = state.actionState == CameraActionState.pickingGallery;
    final maxShots = state.config.maxShotsAllowed ?? 50;

    return GalleryPickerButton(
      isLoading: isPicking,
      onTap: locked ? () {} : () async {
        final notifier = ref.read(scannerControllerProvider.notifier);
        notifier.setActionState(CameraActionState.pickingGallery);
        try {
          final bytesList = await showModalBottomSheet<List<Uint8List>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CustomGalleryBottomSheet(isMultiSelect: true, maxItems: maxShots),
          );

          if (bytesList != null && bytesList.isNotEmpty && context.mounted) {
            for (final b in bytesList) {
              notifier.onImageCaptured(b);
            }
          }
        } finally {
          notifier.setActionState(CameraActionState.idle);
        }
      },
    );
  }

  Widget _buildShutterButton(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerControllerProvider);
    final locked = state.isLocked;
    final isCapturing = state.actionState == CameraActionState.capturing;

    return GestureDetector(
      onTap: locked ? null : () => _takePicture(context, ref),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: isCapturing ? const CircularProgressIndicator(color: Colors.black) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedBadgeButton(BuildContext context, WidgetRef ref) {
    final images = ref.watch(scannerControllerProvider).capturedImages;

    if (images.isEmpty) {
      return const SizedBox(width: 60, height: 60);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CapturedImageGalleryScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.memory(
                    images.last,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
