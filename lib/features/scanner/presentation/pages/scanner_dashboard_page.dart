import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:lens_wise/core/widgets/camera_scanner_view.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/scanner_top_bar.dart';
import 'package:lens_wise/features/scanner/presentation/widgets/scanner_bottom_bar.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/scanner_controller.dart';

class ScannerDashboardPage extends ConsumerWidget {
  const ScannerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch scanner controller to trigger rebuild if necessary, 
    // though the components themselves handle their own reactivity.
    ref.watch(scannerControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraScannerView(
        customOverlayBuilder: (cameraState) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Overlay (Empty for now, full screen immersion)
              const SizedBox.shrink(),

              // 2. Top UI: Settings and History
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ScannerTopBar(),
              ),

              // 3. Bottom UI: Shutter, Mode Switcher, Gallery, Action
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ScannerBottomBar(cameraState: cameraState),
              ),
            ],
          );
        },
      ),
    );
  }
}
