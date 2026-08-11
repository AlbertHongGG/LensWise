import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_draggable_sheet.dart';

class ReceiptResultPage extends ConsumerStatefulWidget {
  const ReceiptResultPage({super.key});

  @override
  ConsumerState<ReceiptResultPage> createState() => _ReceiptResultPageState();
}

class _ReceiptResultPageState extends ConsumerState<ReceiptResultPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptScannerControllerProvider);
    final record = state.receiptRecord;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background to make receipt pop
      body: state.isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text('AI 正在仔細閱讀收據...', style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          : record == null
              ? Center(child: Text(state.errorMessage ?? '無解析結果', style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    // Base Layer: Image Carousel
                    ReceiptImageCarousel(
                      memoryImages: state.capturedImages,
                      filePaths: record.imagePaths,
                    ),
                    
                    // Top Layer: Draggable Paper Receipt Sheet
                    ReceiptDraggableSheet(
                      record: record,
                      onUpdate: _updateRecord,
                    ),
                  ],
                ),
    );
  }

  void _updateRecord(ReceiptRecord updated) {
    ref.read(receiptScannerControllerProvider.notifier).updateReceiptRecord(updated);
  }
}
