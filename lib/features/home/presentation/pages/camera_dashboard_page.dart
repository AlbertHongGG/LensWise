import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/providers/camera_provider.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_controller.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';

class CameraDashboardPage extends ConsumerStatefulWidget {
  const CameraDashboardPage({super.key});

  @override
  ConsumerState<CameraDashboardPage> createState() => _CameraDashboardPageState();
}

class _CameraDashboardPageState extends ConsumerState<CameraDashboardPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraControllerProvider.notifier).initializeCamera();
    });
  }

  Future<void> _takePicture(ScannerModeStrategy strategy, CameraController cameraController) async {
    if (!cameraController.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final xFile = await cameraController.takePicture();
      final bytes = await xFile.readAsBytes();
      
      if (mounted) {
        // Collect image
        strategy.onImageCaptured(bytes);
        
        if (strategy.isAutoProcess && strategy.hasReachedMinShots) {
          // Process and Navigate
          await strategy.processImage(context, ref);
          // Reset for next time
          strategy.reset();
        } else {
          // Just force a rebuild to update the overlay (e.g. shot counter or show Done button)
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to take picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    final mode = ref.watch(scannerModeProvider);
    final strategy = ref.read(scannerModeProvider.notifier).currentStrategy;
    final cameraState = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Layer: Live Camera
          CameraScannerView(
            controller: cameraState.controller,
            isInitialized: cameraState.isInitialized,
          ),
          
          // 2. Middle Layer: Mode-specific Overlay
          strategy.buildOverlay(context),

          // 3. Top Gradient overlay for icons
          // 3. Top Gradient overlay for icons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                ),
              ),
            ),
          ),

          // 4. Top UI: Settings and History
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: _buildTopIconButton(
              icon: Icons.settings,
              onTap: () => context.push('/settings'),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: _buildTopIconButton(
              icon: Icons.history,
              onTap: () {
                // Navigate to the respective history based on mode
                switch (mode) {
                  case ScannerMode.receipt:
                    context.push('/history/receipts');
                    break;
                  case ScannerMode.product:
                    context.push('/history/products');
                    break;
                  case ScannerMode.comparison:
                    context.push('/history/comparisons');
                    break;
                }
              },
            ),
          ),

          // 5. Bottom UI: Shutter and Mode Switcher
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating "Done" Button for manual processing
                if (!strategy.isAutoProcess && strategy.hasReachedMinShots)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() { _isProcessing = true; });
                        try {
                          await strategy.processImage(context, ref);
                          strategy.reset();
                        } finally {
                          if (mounted) setState(() { _isProcessing = false; });
                        }
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: Text('開始比對 (${strategy.capturedImages.length} 項)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 8,
                      ),
                    ),
                  ),

                  // Shutter Button
                  GestureDetector(
                    onTap: () {
                      if (cameraState.isInitialized && cameraState.controller != null) {
                        _takePicture(strategy, cameraState.controller!);
                      }
                    },
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
                          child: _isProcessing 
                              ? const CircularProgressIndicator(color: Colors.black)
                              : null,
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Google Lens Style Mode Switcher Pill
                _buildModeSwitcher(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.3),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    final mode = ref.watch(scannerModeProvider);
    final modes = [
      {'label': '翻譯', 'mode': ScannerMode.receipt}, // For testing layout, receipt translates to document etc.
      {'label': '商品', 'mode': ScannerMode.product},
      {'label': '比對', 'mode': ScannerMode.comparison},
    ];

    // Using "收據" for receipt
    modes[0]['label'] = '收據';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((m) {
              final isSelected = mode == m['mode'];
              return GestureDetector(
                onTap: () {
                  // Reset previous strategy before switching
                  ref.read(scannerModeProvider.notifier).currentStrategy.reset();
                  ref.read(scannerModeProvider.notifier).setMode(m['mode'] as ScannerMode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    m['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
