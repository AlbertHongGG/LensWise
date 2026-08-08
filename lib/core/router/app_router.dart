import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lens_wise/features/home/presentation/pages/scaffold_with_bottom_nav_bar.dart';
import 'package:lens_wise/features/history/presentation/pages/receipt_history_page.dart';
import 'package:lens_wise/features/history/presentation/pages/product_history_page.dart';
import 'package:lens_wise/features/history/presentation/pages/comparison_history_page.dart';
import 'package:lens_wise/features/settings/presentation/pages/settings_page.dart';

import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_scanner_page.dart';
import 'package:lens_wise/features/product_lens/presentation/pages/product_lens_page.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/product_comparison_scanner_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorReceiptKey = GlobalKey<NavigatorState>(debugLabel: 'receiptTab');
final GlobalKey<NavigatorState> _shellNavigatorProductKey = GlobalKey<NavigatorState>(debugLabel: 'productTab');
final GlobalKey<NavigatorState> _shellNavigatorComparisonKey = GlobalKey<NavigatorState>(debugLabel: 'comparisonTab');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settingsTab');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/receipts',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Receipt History
          StatefulShellBranch(
            navigatorKey: _shellNavigatorReceiptKey,
            routes: [
              GoRoute(
                path: '/receipts',
                builder: (context, state) => const ReceiptHistoryPage(),
              ),
            ],
          ),
          // Tab 1: Product History
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProductKey,
            routes: [
              GoRoute(
                path: '/products',
                builder: (context, state) => const ProductHistoryPage(),
              ),
            ],
          ),
          // Tab 2: Comparison History
          StatefulShellBranch(
            navigatorKey: _shellNavigatorComparisonKey,
            routes: [
              GoRoute(
                path: '/comparisons',
                builder: (context, state) => const ComparisonHistoryPage(),
              ),
            ],
          ),
          // Tab 3: Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      
      // Global Modals/Scanners outside of Bottom Nav (Cover full screen)
      GoRoute(
        path: '/receipt_scanner',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage(
          child: const ReceiptScannerPage(),
        ),
      ),
      GoRoute(
        path: '/product_scanner',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage(
          child: const ProductLensPage(), // Actually the Scanner for single product
        ),
      ),
      GoRoute(
        path: '/comparison_scanner',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CupertinoPage(
          child: const ProductComparisonScannerPage(),
        ),
      ),
    ],
  );
});
