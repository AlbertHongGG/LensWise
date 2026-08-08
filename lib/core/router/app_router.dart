import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lens_wise/features/home/presentation/pages/camera_dashboard_page.dart';
import 'package:lens_wise/features/settings/presentation/pages/settings_page.dart';
import 'package:lens_wise/features/ai/presentation/screens/ai_settings_screen.dart';

// History Pages
import 'package:lens_wise/features/history/presentation/pages/unified_history_page.dart';

// Result Pages
import 'package:lens_wise/features/product_lens/presentation/pages/product_result_page.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_result_page.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // The ONE AND ONLY root page: Camera
      GoRoute(
        path: '/',
        builder: (context, state) => const CameraDashboardPage(),
      ),
      
      // Global Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/settings/ai',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: AiSettingsScreen(),
        ),
      ),

      // Result Pages
      GoRoute(
        path: '/result/product',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: ProductResultPage(),
        ),
      ),
      GoRoute(
        path: '/result/receipt',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: ReceiptResultPage(),
        ),
      ),
      GoRoute(
        path: '/result/comparison',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: ComparisonResultPage(),
        ),
      ),

      // History Pages
      GoRoute(
        path: '/history',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final tabIndexStr = state.uri.queryParameters['tab'];
          final initialIndex = tabIndexStr != null ? int.tryParse(tabIndexStr) ?? 0 : 0;
          return CupertinoPage(
            child: UnifiedHistoryPage(initialTabIndex: initialIndex),
          );
        },
      ),
    ],
  );
});
