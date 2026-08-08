import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final List<Uint8List> capturedImages = [];

  /// Called when a new image is captured.
  void onImageCaptured(Uint8List image) {
    if (maxShotsAllowed == null || capturedImages.length < maxShotsAllowed!) {
      capturedImages.add(image);
    }
  }

  /// Checks if enough images have been captured to proceed manually or automatically.
  bool get hasReachedMinShots => capturedImages.length >= minShotsRequired;

  /// Resets the current session.
  void reset() {
    capturedImages.clear();
  }

  /// Builds the overlay widget (e.g., targeting brackets) for the camera.
  Widget buildOverlay(BuildContext context);

  /// Processes the captured images. It handles calling the AI agent and navigating to the result page.
  Future<void> processImage(BuildContext context, WidgetRef ref);
}
