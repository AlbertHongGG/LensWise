import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_paper_card.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF5F5F5);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  ReceiptPaperCard(
                    record: _currentRecord,
                    onUpdate: _updateRecord,
                  ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
            if (_currentRecord.imagePaths.isNotEmpty || (widget.memoryImages?.isNotEmpty ?? false))
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isDrawerOpen ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: () => setState(() => _isDrawerOpen = true),
                      backgroundColor: isDark ? Colors.white24 : Colors.black87,
                      foregroundColor: isDark ? Colors.white : Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ),
            if (_isDrawerOpen)
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= 0.05) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _isDrawerOpen) {
                        setState(() => _isDrawerOpen = false);
                      }
                    });
                  }
                  return false;
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.0,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
                        // Drag handle area
                        SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Independent scroll/zoom for image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          child: ReceiptImageCarousel(
                            memoryImages: widget.memoryImages ?? [],
                            filePaths: _currentRecord.imagePaths,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
