import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/widgets/menu_chat_adapter.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';

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
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA); // Slight off-white
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937); // Tailored dark text

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Scrollable Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                _buildSliverHeader(context, isDark, textColor),
                _buildSliverList(context, isDark, textColor),
                SliverToBoxAdapter(
                  child: SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
                ), // Space for FABs
              ],
            ),
            
            // Floating Buttons
            _buildFloatingActionButtons(context, isDark),
            
            // Image Drawer
            if (_isDrawerOpen)
              _buildImageDrawer(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, bool isDark, Color textColor) {
    final title = _currentRecord.storeName.isNotEmpty ? _currentRecord.storeName : '翻譯菜單';
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentRecord.items.length} 個品項',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverList(BuildContext context, bool isDark, Color textColor) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _currentRecord.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildMenuItem(item, isDark, textColor),
            );
          },
          childCount: _currentRecord.items.length,
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuScannerItem item, bool isDark, Color textColor) {
    final hasDescription = item.description != null && item.description!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.translatedName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.originalName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              item.price > 0 ? item.price.toStringAsFixed(0) : '-',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        if (hasDescription) ...[
          const SizedBox(height: 8),
          Text(
            item.description!,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Divider(
          height: 1, 
          thickness: 1, 
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, bool isDark) {
    final buttonColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFF1F2937);
    final iconColor = Colors.white;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _isDrawerOpen ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentRecord.imagePaths.isNotEmpty || (widget.memoryImages?.isNotEmpty ?? false)) ...[
              _buildSquircleButton(
                icon: Icons.image_outlined,
                color: buttonColor,
                iconColor: iconColor,
                onTap: () => setState(() => _isDrawerOpen = true),
              ),
              const SizedBox(width: 16),
            ],
            _buildSquircleButton(
              icon: Icons.auto_awesome,
              color: buttonColor,
              iconColor: iconColor,
              onTap: () => showMenuChat(context, _currentRecord),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquircleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildImageDrawer(bool isDark) {
    return NotificationListener<DraggableScrollableNotification>(
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
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -8),
              )
            ],
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
    );
  }
}
