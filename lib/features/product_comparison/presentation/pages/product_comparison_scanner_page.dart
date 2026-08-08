import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/core/widgets/thinking_orb.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_comparison_agent/product_comparison_agent.dart';
import 'product_comparison_result_page.dart';

class ProductComparisonScannerPage extends ConsumerStatefulWidget {
  const ProductComparisonScannerPage({super.key});

  @override
  ConsumerState<ProductComparisonScannerPage> createState() => _ProductComparisonScannerPageState();
}

class _ProductComparisonScannerPageState extends ConsumerState<ProductComparisonScannerPage> {
  CameraController? _cameraController;

  void _onCameraCreated(CameraController controller) {
    _cameraController = controller;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      ref.read(productComparisonScannerControllerProvider.notifier).addImage(bytes);
    } catch (e) {
      debugPrint('[ERROR] Capture failed: $e');
    }
  }

  Future<void> _startComparison() async {
    final state = ref.read(productComparisonScannerControllerProvider);
    if (state.capturedImages.isEmpty) return;

    final notifier = ref.read(productComparisonScannerControllerProvider.notifier);
    notifier.setAnalyzing(true);

    try {
      final agent = ref.read(productComparisonAgentProvider);
      final result = await agent.execute(state.capturedImages);

      notifier.setAnalyzing(false);

      if (result.status == 'success' && result.data != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductComparisonResultPage(resultData: result.data!),
          ),
        );
      } else {
        notifier.setError(result.message ?? '比對失敗，請稍後再試。');
      }
    } catch (e) {
      notifier.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productComparisonScannerControllerProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CameraScannerView(
            onCameraControllerCreated: _onCameraCreated,
          ),
          
          // Header / Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '拍攝商品進行比對',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: isDark ? Colors.black : Colors.white70, blurRadius: 4)],
                ),
              ),
            ),
          ),

          // Error Message
          if (state.errorMessage != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Loading Overlay
          if (state.isAnalyzing)
            Container(
              color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThinkingOrb(size: 80, isDark: isDark),
                    const SizedBox(height: 24),
                    Text(
                      'AI 正在深度比對中...',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls (Thumbnails & Capture)
          if (!state.isAnalyzing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Thumbnails
                  if (state.capturedImages.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.capturedImages.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 60,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: isDark ? Colors.white : Colors.black54, width: 2),
                                  image: DecorationImage(
                                    image: MemoryImage(state.capturedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    ref.read(productComparisonScannerControllerProvider.notifier).removeImage(index);
                                  },
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Capture Button
                  GestureDetector(
                    onTap: _captureImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: isDark ? Colors.white : Colors.black54, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Start Comparison FAB
          if (state.capturedImages.isNotEmpty && !state.isAnalyzing)
            Positioned(
              bottom: 60,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: _startComparison,
                backgroundColor: Colors.blueAccent,
                icon: const Icon(Icons.compare_arrows, color: Colors.white),
                label: const Text('開始比對', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
