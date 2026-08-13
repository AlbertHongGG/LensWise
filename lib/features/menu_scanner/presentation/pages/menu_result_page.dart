import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/widgets/menu_chat_adapter.dart';
import 'package:lens_wise/features/menu_scanner/presentation/widgets/menu_list_item_tile.dart';
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
    final bgColor = isDark ? Colors.black : const Color(0xFFF8F9FA); 
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937); 

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 全板塊滑動 (The Scrolling Card Layout)
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, isDark, textColor),
                    _buildList(context, isDark, textColor),
                    const SizedBox(height: 32), // 底部留白
                  ],
                ),
              ),
            ),
            
            // 底部操作按鈕
            _buildFloatingActionButtons(context, isDark),
            
            // 圖片抽屜
            if (_isDrawerOpen)
              _buildImageDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor) {
    final title = _currentRecord.storeName.isNotEmpty ? _currentRecord.storeName : '翻譯菜單';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
              color: textColor,
              height: 1.2,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_currentRecord.items.length} 個品項',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_currentRecord.items.length, (index) {
          final item = _currentRecord.items[index];
          final isLast = index == _currentRecord.items.length - 1;
          
          return MenuListItemTile(
            item: item,
            isDark: isDark,
            textColor: textColor,
            isLast: isLast,
          );
        }),
      ),
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

  Widget _buildImageDrawer() {
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
          decoration: const BoxDecoration(
            color: Colors.black, // 保持與收據頁面一致的純黑背景
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              // 拖拉把手區域 (與收據頁面完全一致)
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
