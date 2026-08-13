import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_mode_config.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/scanner_controller.dart';

class ScannerTopBar extends ConsumerWidget {
  const ScannerTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.settings,
            onTap: () => context.push('/settings'),
          ),
          _buildIconButton(
            icon: Icons.history,
            onTap: () {
              final mode = ref.read(scannerControllerProvider).currentMode;
              switch (mode) {
                case ScannerMode.receipt: context.push('/history?tab=0'); break;
                case ScannerMode.product: context.push('/history?tab=1'); break;
                case ScannerMode.comparison: context.push('/history?tab=2'); break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
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
}
