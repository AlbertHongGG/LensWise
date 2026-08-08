import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScannerView extends StatefulWidget {
  final Widget? overlay;
  final Function(CameraController) onCameraControllerCreated;

  const CameraScannerView({
    super.key,
    this.overlay,
    required this.onCameraControllerCreated,
  });

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          widget.onCameraControllerCreated(_controller!);
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Camera init failed: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        if (widget.overlay != null) widget.overlay!,
      ],
    );
  }
}
