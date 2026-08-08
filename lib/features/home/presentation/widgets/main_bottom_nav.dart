import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onAddTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onAddTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: GlassContainer(
        opacity: 0.1,
        blur: 20,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, FontAwesomeIcons.receipt, '收據'),
              _buildNavItem(context, 1, FontAwesomeIcons.boxOpen, '商品'),
              _buildCenterAddButton(context),
              _buildNavItem(context, 2, FontAwesomeIcons.codeCompare, '比對'),
              _buildNavItem(context, 3, FontAwesomeIcons.gear, '設定'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddTapped,
      child: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const FaIcon(
          FontAwesomeIcons.camera,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, dynamic icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              )
            : null,
        child: icon is IconData
            ? Icon(icon, color: isSelected ? Theme.of(context).primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54), size: 20)
            : FaIcon(icon, color: isSelected ? Theme.of(context).primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54), size: 20),
      ),
    );
  }
}
