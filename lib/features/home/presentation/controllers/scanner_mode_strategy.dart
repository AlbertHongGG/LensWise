import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:camerawesome/camerawesome_plugin.dart';

abstract class ScannerModeStrategy {
  /// The title for the current mode, displayed at the top or in the mode switcher.
  String get modeTitle;

  /// Minimum number of shots required before processing is allowed.
  int get minShotsRequired => 1;

  /// Maximum number of shots allowed. null means infinite.
  int? get maxShotsAllowed => 1;
  
  /// If true, processImage is automatically called when minShotsRequired is reached.
  /// If false, the UI should present a "Done" button when minShotsRequired is reached.
  bool get isAutoProcess => true;

  /// The images captured so far in the current session.
  final ValueNotifier<List<Uint8List>> capturedImages = ValueNotifier([]);

  /// True if the strategy is currently processing an image (e.g., AI request).
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  /// Called when a new image is captured.
  void onImageCaptured(Uint8List image) {
    if (maxShotsAllowed == null || capturedImages.value.length < maxShotsAllowed!) {
      capturedImages.value = [...capturedImages.value, image];
    }
  }

  /// Called to remove a specific image by index.
  void removeImage(int index) {
    if (index >= 0 && index < capturedImages.value.length) {
      final updatedList = List<Uint8List>.from(capturedImages.value)..removeAt(index);
      capturedImages.value = updatedList;
    }
  }

  /// Checks if enough images have been captured to proceed manually or automatically.
  bool get hasReachedMinShots => capturedImages.value.length >= minShotsRequired;

  /// Resets the current session.
  void reset() {
    capturedImages.value = [];
  }

  /// Builds the overlay widget (e.g., targeting brackets) for the camera.
  Widget buildOverlay(BuildContext context);

  /// Builds a floating action widget positioned above the shutter (e.g., Done button).
  Widget buildFloatingAction(BuildContext context, WidgetRef ref) => const SizedBox.shrink();

  /// Builds the action widget on the left side of the shutter (e.g., Gallery).
  Widget buildLeftBottomAction(BuildContext context, WidgetRef ref) => const SizedBox(width: 60, height: 60);

  /// Builds the action widget on the right side of the shutter (e.g., Local Album picker).
  Widget buildRightBottomAction(BuildContext context, WidgetRef ref) => const SizedBox(width: 60, height: 60);

  /// Builds the center shutter button.
  /// A default implementation is provided which calls [defaultTakePicture].
  Widget buildShutterButton(BuildContext context, WidgetRef ref, dynamic cameraState, Future<void> Function() defaultTakePicture) {
    return ValueListenableBuilder<bool>(
      valueListenable: isProcessing,
      builder: (context, processing, child) {
        return GestureDetector(
          onTap: processing ? null : defaultTakePicture,
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
                child: processing ? const CircularProgressIndicator(color: Colors.black) : null,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Processes the captured images. It handles calling the AI agent and navigating to the result page.
  Future<void> processImage(BuildContext context, WidgetRef ref);
}
