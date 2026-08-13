import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/storage/history_providers.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/widgets/menu_chat_adapter.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';

class MenuResultPage extends ConsumerStatefulWidget {
  final MenuScannerRecord record;
  final List<Uint8List>? memoryImages;

  const MenuResultPage({
    super.key,
    required this.record,
    this.memoryImages,
  });

  @override
  ConsumerState<MenuResultPage> createState() => _MenuResultPageState();
}

class _MenuResultPageState extends ConsumerState<MenuResultPage> {
  late MenuScannerRecord _currentRecord;
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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(_currentRecord.storeName.isNotEmpty ? _currentRecord.storeName : '菜單解析結果'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildMenuCard(context, isDark),
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
                        heroTag: 'menu_image_btn',
                        onPressed: () => setState(() => _isDrawerOpen = true),
                        backgroundColor: isDark ? Colors.white24 : Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(Icons.image_outlined),
                      ),
                      const SizedBox(width: 16),
                    ],
                    FloatingActionButton(
                      heroTag: 'menu_ai_btn',
                      onPressed: () => showMenuChat(context, _currentRecord),
                      backgroundColor: Theme.of(context).primaryColor,
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
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: Column(
                      children: [
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
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildMenuCard(BuildContext context, bool isDark) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      color: Colors.white,
      opacity: isDark ? 0.05 : 0.8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '翻譯菜單',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._currentRecord.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.translatedName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            item.price > 0 ? item.price.toStringAsFixed(0) : '-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.originalName,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      if (item.description != null && item.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(height: 1, thickness: 1),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
