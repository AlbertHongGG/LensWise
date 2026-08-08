import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ScannerModeStrategy {
  /// The title for the current mode, displayed at the top or in the mode switcher.
  String get modeTitle;

  /// Number of shots required before processing.
  int get requiredShots => 1;

  /// The images captured so far in the current session.
  final List<Uint8List> capturedImages = [];

  /// Called when a new image is captured.
  void onImageCaptured(Uint8List image) {
    if (capturedImages.length < requiredShots) {
      capturedImages.add(image);
    }
  }

  /// Checks if enough images have been captured to proceed.
  bool get isReadyToProcess => capturedImages.length >= requiredShots;

  /// Resets the current session.
  void reset() {
    capturedImages.clear();
  }

  /// Builds the overlay widget (e.g., targeting brackets) for the camera.
  Widget buildOverlay(BuildContext context);

  /// Processes the captured images. It handles calling the AI agent and navigating to the result page.
  Future<void> processImage(BuildContext context, WidgetRef ref);
}
