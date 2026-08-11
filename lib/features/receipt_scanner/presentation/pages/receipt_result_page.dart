import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_draggable_sheet.dart';

class ReceiptResultPage extends ConsumerStatefulWidget {
  final ReceiptRecord record;
  final List<Uint8List>? memoryImages;

  const ReceiptResultPage({
    super.key,
    required this.record,
    this.memoryImages,
  });

  @override
  ConsumerState<ReceiptResultPage> createState() => _ReceiptResultPageState();
}

class _ReceiptResultPageState extends ConsumerState<ReceiptResultPage> {
  late ReceiptRecord _currentRecord;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background to make receipt pop
      body: Stack(
        children: [
          // Base Layer: Image Carousel
          ReceiptImageCarousel(
            memoryImages: widget.memoryImages ?? [],
            filePaths: _currentRecord.imagePaths,
          ),
          
          // Top Layer: Draggable Paper Receipt Sheet
          ReceiptDraggableSheet(
            record: _currentRecord,
            onUpdate: _updateRecord,
          ),
        ],
      ),
    );
  }

  Future<void> _updateRecord(ReceiptRecord updated) async {
    setState(() {
      _currentRecord = updated;
    });
    try {
      final repository = ref.read(receiptRepositoryProvider);
      await repository.save(updated.id, updated);
      ref.invalidate(receiptHistoryProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e')),
        );
      }
    }
  }
}
