import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/core/storage/storage_providers.dart';
import 'dart:io';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_paper_card.dart';
import 'package:lens_wise/core/utils/app_paths.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/receipt_chat_adapter.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class ReceiptResultPage extends ConsumerStatefulWidget {
  final ReceiptScannerRecord record;
  final List<AppImageEntity>? memoryImages;

  const ReceiptResultPage({
    super.key,
    required this.record,
    this.memoryImages,
  });

  @override
  ConsumerState<ReceiptResultPage> createState() => _ReceiptResultPageState();
}

class _ReceiptResultPageState extends ConsumerState<ReceiptResultPage> {
  late ReceiptScannerRecord _currentRecord;
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
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _isDrawerOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentRecord.imagePaths.isNotEmpty || (widget.memoryImages?.isNotEmpty ?? false)) ...[
                      FloatingActionButton(
                        heroTag: 'receipt_image_btn',
                        onPressed: () => setState(() => _isDrawerOpen = true),
                        backgroundColor: isDark ? Colors.white24 : Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.image_outlined),
                      ),
                      const SizedBox(width: 16),
                    ],
                    FloatingActionButton(
                      heroTag: 'receipt_ai_btn',
                      onPressed: () => showReceiptChat(context, _currentRecord),
                      backgroundColor: isDark ? Colors.white24 : Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      child: const Icon(Icons.auto_awesome),
                    ),
                  ],
                ),
              ),
            ),
            if (_isDrawerOpen)
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent <= 0.1) {
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
                  minChildSize: 0.1,
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
                            items: [
                              ...(List.generate(_currentRecord.imagePaths.length, (i) {
                                final path = _currentRecord.imagePaths[i];
                                final memoryImage = widget.memoryImages != null && widget.memoryImages!.length > i 
                                    ? widget.memoryImages![i] : null;
                                
                                return CarouselItem(
                                  image: memoryImage != null 
                                      ? ResizeImage(MemoryImage(memoryImage.bytes), width: 1080) 
                                      : ResizeImage(FileImage(AppPaths.getImageFile(path)), width: 1080) as ImageProvider,
                                  fit: memoryImage?.source == ImageSourceType.camera ? BoxFit.cover : BoxFit.contain,
                                );
                              })),
                            ],
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

  Future<void> _updateRecord(ReceiptScannerRecord updated) async {
    setState(() {
      _currentRecord = updated;
    });
    try {
      final repository = ref.read(receiptScannerRepositoryProvider);
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
