import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_state.dart';
import 'package:lens_wise/features/scanner/domain/models/scanner_mode_config.dart';
import 'package:lens_wise/features/scanner/presentation/controllers/scanner_controller.dart';

class ScannerActionButton extends ConsumerWidget {
  const ScannerActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerControllerProvider);
    
    if (!state.hasReachedMinShots) {
      return const SizedBox.shrink();
    }

    final isAnalyzing = state.actionState == CameraActionState.analyzing;
    final isLocked = state.isLocked;
    
    Color shadowColor;
    IconData iconData;
    String labelText;
    
    switch (state.currentMode) {
      case ScannerMode.product:
        shadowColor = Colors.blueAccent;
        iconData = Icons.search;
        labelText = '開始分析';
        break;
      case ScannerMode.comparison:
        shadowColor = Colors.purpleAccent;
        iconData = Icons.compare;
        labelText = '開始比對';
        break;
      case ScannerMode.receipt:
        shadowColor = Colors.blueAccent;
        iconData = Icons.receipt_long;
        labelText = '開始解析';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () => ref.read(scannerControllerProvider.notifier).processImages(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAnalyzing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              else
                Icon(iconData, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                labelText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
