import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

class CameraScannerView extends StatefulWidget {
  final Widget Function(CameraController controller) customOverlayBuilder;
  final VoidCallback? onCameraReady;

  const CameraScannerView({
    super.key,
    required this.customOverlayBuilder,
    this.onCameraReady,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      if (_controller!.value.flashMode != FlashMode.off) {
        await _controller!.setFlashMode(FlashMode.off);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        widget.onCameraReady?.call();
      }
    } catch (e) {
      debugPrint('[ERROR] Camera init failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      _isInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // Force strict visual alignment mapping
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Precise Camera Render Layer - perfectly centered and bound
          Center(
            child: CameraPreview(_controller!),
          ),
          
          // 2. Custom Overlay Layer
          widget.customOverlayBuilder(_controller!),
        ],
      ),
    );
  }
}
