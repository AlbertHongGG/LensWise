import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'receipt_paper_card.dart';

class ReceiptDraggableSheet extends StatelessWidget {
  final ReceiptRecord record;
  final Function(ReceiptRecord) onUpdate;

  const ReceiptDraggableSheet({
    super.key,
    required this.record,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25, // Increased to keep the store name and date always visible at the bottom
      maxChildSize: 0.9,  // Allows pulling up to read full text
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Column(
                children: [
                  // Drag Handle Area (Attached to scrollController for dragging the sheet)
                  SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black26,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Independent Scrollable Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            ReceiptPaperCard(
                              record: record,
                              onUpdate: onUpdate,
                            ),
                            const SizedBox(height: 64), // Safe area bottom padding
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
