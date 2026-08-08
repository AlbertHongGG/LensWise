import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
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

  Future<void> _takePicture(ScannerModeStrategy strategy, CameraState cameraState) async {
    if (_isProcessing) return;
    
    setState(() { _isProcessing = true; });

    try {
      // Capture photo using camerawesome
      cameraState.when(
        onPhotoMode: (photoState) async {
          final request = await photoState.takePhoto();
          final path = request.when(
            single: (single) => single.file?.path,
            multiple: (multiple) => multiple.fileBySensor.values.first?.path,
          );
          
          if (path != null && mounted) {
            final bytes = await File(path).readAsBytes();
            
            strategy.onImageCaptured(bytes);
            
            if (strategy.isAutoProcess && strategy.hasReachedMinShots) {
              await strategy.processImage(context, ref);
              strategy.reset();
            } else {
              setState(() {});
            }
          }
        }
      );
    } catch (e) {
      debugPrint('[ERROR] Failed to take picture: $e');
    } finally {
      if (mounted) {
        setState(() { _isProcessing = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraScannerView(
        customOverlayBuilder: (cameraState) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Mode-specific Overlay
              ref.read(scannerModeProvider.notifier).currentStrategy.buildOverlay(context),

              // 2. Top UI: Settings and History
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
                    final mode = ref.read(scannerModeProvider);
                    switch (mode) {
                      case ScannerMode.receipt: context.push('/history/receipts'); break;
                      case ScannerMode.product: context.push('/history/products'); break;
                      case ScannerMode.comparison: context.push('/history/comparisons'); break;
                    }
                  },
                ),
              ),

              // 3. Bottom UI: Shutter and Mode Switcher
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDoneButton(ref.read(scannerModeProvider.notifier).currentStrategy),
                    _buildShutterButton(ref.read(scannerModeProvider.notifier).currentStrategy, cameraState),
                    const SizedBox(height: 24),
                    _buildModeSwitcher(),
                  ],
                ),
              ),
            ],
          );
        },
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

  Widget _buildDoneButton(ScannerModeStrategy strategy) {
    if (strategy.isAutoProcess || !strategy.hasReachedMinShots) return const SizedBox.shrink();
    return Padding(
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildShutterButton(ScannerModeStrategy strategy, CameraState cameraState) {
    return GestureDetector(
      onTap: () => _takePicture(strategy, cameraState),
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
            child: _isProcessing ? const CircularProgressIndicator(color: Colors.black) : null,
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    final mode = ref.watch(scannerModeProvider);
    final modes = [
      {'label': '收據', 'mode': ScannerMode.receipt},
      {'label': '商品', 'mode': ScannerMode.product},
      {'label': '比對', 'mode': ScannerMode.comparison},
    ];

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
              ref.read(scannerModeProvider.notifier).currentStrategy.reset();
              ref.read(scannerModeProvider.notifier).setMode(m['mode'] as ScannerMode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Text(
                m['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
