import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/product_result_card.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_agent.dart';

class ProductLensPage extends ConsumerStatefulWidget {
  const ProductLensPage({super.key});

  @override
  ConsumerState<ProductLensPage> createState() => _ProductLensPageState();
}

class _ProductLensPageState extends ConsumerState<ProductLensPage> {
  CameraController? _cameraController;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productLensControllerProvider);
    final isLoading = state.status == ProductLensStatus.loading;
    final hasResult = state.status == ProductLensStatus.success || state.status == ProductLensStatus.error;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera View
          CameraScannerView(
            onCameraControllerCreated: (controller) {
              _cameraController = controller;
            },
            overlay: _buildGuidanceOverlay(),
          ),

          // 2. Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'AI is analyzing the product...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Shutter Button
          if (!isLoading && !hasResult)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 4. Result Bottom Sheet (Rendered inline as positioned for smooth overlay)
          if (hasResult)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ProductResultCard(
                result: state.result ?? ProductAnalysisResult(status: 'error', message: state.errorMessage),
                onClose: () {
                  ref.read(productLensControllerProvider.notifier).reset();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuidanceOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.75;
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
                child: Center(
                  child: Container(
                    width: boxSize,
                    height: boxSize * 1.2,
                    decoration: BoxDecoration(
                      color: Colors.white, // Color does not matter due to blend mode
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: boxSize,
                height: boxSize * 1.2,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Text(
                'Align the product within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      ref.read(productLensControllerProvider.notifier).analyzeImage(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );
      }
    }
  }
}
