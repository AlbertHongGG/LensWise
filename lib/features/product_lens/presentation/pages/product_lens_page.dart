import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/core/widgets/thinking_orb.dart';
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThinkingOrb(size: 80, isDark: isDark),
                    const SizedBox(height: 24),
                    Text(
                      'AI 智慧解析中...',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
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
                      border: Border.all(color: isDark ? Colors.white : Colors.black54, width: 4),
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white : Colors.black87,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final boxSize = constraints.maxWidth * 0.75;
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
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
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.3), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Text(
                'Align the product within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: isDark ? Colors.black54 : Colors.white54, blurRadius: 4, offset: const Offset(0, 2))
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
