import 'package:flutter/material.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

class MenuListItemTile extends StatelessWidget {
  final MenuScannerItem item;
  final bool isDark;
  final Color textColor;
  final bool isLast;

  const MenuListItemTile({
    super.key,
    required this.item,
    required this.isDark,
    required this.textColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = item.description != null && item.description!.isNotEmpty;
    final primaryColor = Theme.of(context).primaryColor;
    
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
                      fontSize: 17,
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
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ],
        ),
        if (hasDescription) ...[
          const SizedBox(height: 12),
          // 方案 A：引言區塊設計 (The Quote Block)
          Container(
            padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: primaryColor.withValues(alpha: 0.6), // 精緻的左側提示線
                  width: 3,
                ),
              ),
            ),
            child: Text(
              item.description!,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
        // 極微弱的定海神針分隔線
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.08) 
                  : Colors.black.withValues(alpha: 0.05),
            ),
          )
        else
          const SizedBox(height: 20),
      ],
    );
  }
}
