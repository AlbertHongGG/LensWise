import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/home/presentation/widgets/main_bottom_nav.dart';

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onAddTapped(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    if (currentIndex == 0) {
      context.push('/receipt_scanner');
    } else if (currentIndex == 1) {
      context.push('/product_scanner');
    } else if (currentIndex == 2) {
      context.push('/comparison_scanner');
    }
    // Tab 3 is Settings, no scanner for that
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onItemTapped: (index) => _onItemTapped(index, context),
        onAddTapped: () => _onAddTapped(context),
      ),
    );
  }
}
