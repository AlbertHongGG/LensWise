import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/engine/stitching_engine.dart';

class ReceiptScannerPage extends ConsumerStatefulWidget {
  const ReceiptScannerPage({super.key});

  @override
  ConsumerState<ReceiptScannerPage> createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends ConsumerState<ReceiptScannerPage> {
  CameraController? _cameraController;

  @override
  void dispose() {
    if (_cameraController?.value.isStreamingImages == true) {
      _cameraController?.stopImageStream();
    }
    super.dispose();
  }

  void _onCameraCreated(CameraController controller) {
    _cameraController = controller;
  }

  void _toggleScanning() async {
    final state = ref.read(receiptScannerControllerProvider);
    final notifier = ref.read(receiptScannerControllerProvider.notifier);

    if (state.isScanning) {
      // Stop
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController?.stopImageStream();
      }
      notifier.stopScanning();
    } else {
      // Start
      notifier.startScanning();
      if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
        _cameraController!.startImageStream((image) {
          ref.read(receiptScannerControllerProvider.notifier).processCameraImage(image);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScannerControllerProvider);
    
    // Determine UI colors based on engine state
    Color overlayColor = Colors.greenAccent;
    String statusText = "慢慢向下移動...";
    
    if (state.engineState == EngineState.alignmentLost || state.engineState == EngineState.recovering) {
      overlayColor = Colors.redAccent;
      statusText = "追蹤丟失！請往回移動對齊";
    }
    if (!state.isScanning) {
      overlayColor = Colors.white54;
      statusText = "對準收據頂部，按下開始";
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CameraScannerView(
            // Use streaming format appropriate for platform
            imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
            onCameraControllerCreated: _onCameraCreated,
            overlay: _buildOverlay(overlayColor, statusText, state.stitchedHeight),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (state.isScanning)
                  Text(
                    "已掃描長度: ${state.stitchedHeight} px",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _toggleScanning,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isScanning ? theme.colorScheme.error : (isDark ? Colors.white : Colors.black12),
                      border: Border.all(color: isDark ? Colors.white54 : Colors.black26, width: 4),
                    ),
                    child: Center(
                      child: Icon(
                        state.isScanning ? Icons.stop : Icons.camera_alt,
                        color: state.isScanning ? theme.colorScheme.onError : (isDark ? Colors.black : Colors.black87),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(Color color, String text, int height) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: 0.5), 
          width: 4,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white70, blurRadius: 4)],
            ),
          ),
          if (height > 0)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(Icons.arrow_downward, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, size: 32),
            )
        ],
      ),
    );
  }
}
