import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lens_wise/features/scanner/presentation/pages/scanner_dashboard_page.dart';
import 'package:lens_wise/features/settings/presentation/pages/settings_page.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/features/ai/presentation/screens/ai_settings_screen.dart';
import 'package:lens_wise/core/presentation/pages/splash_animation_page.dart';

// History Pages
import 'package:lens_wise/features/history/presentation/pages/unified_history_page.dart';
import 'package:lens_wise/features/history/presentation/pages/default_history_configs.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_processing_page.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/features/product_lens/presentation/pages/product_processing_page.dart';
import 'package:lens_wise/features/product_lens/presentation/pages/product_detail_page.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

// Result Pages
import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_processing_page.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_result_page.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_page.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/pages/menu_processing_page.dart';
import 'package:lens_wise/features/menu_scanner/presentation/pages/menu_result_page.dart';
import 'package:lens_wise/core/router/global_navigator.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashAnimationPage(),
      ),
      // Main Dashboard
      GoRoute(
        path: '/scanner',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ScannerDashboardPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeIn).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/process/product',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final images = state.extra as List<AppImageEntity>? ?? [];
          return CupertinoPage(
            child: ProductProcessingPage(memoryImages: images),
          );
        },
      ),
      GoRoute(
        path: '/product/processing',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final images = state.extra as List<AppImageEntity>? ?? [];
          return CupertinoPage(
            child: ProductProcessingPage(memoryImages: images),
          );
        },
      ),
      GoRoute(
        path: '/result/product',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final record = extra?['record'] as ProductLensRecord?;
          final memoryImages = (extra?['memoryImages'] ?? extra?['appImages']) as List<AppImageEntity>?;

          if (record == null) {
            return const CupertinoPage(
              child: Scaffold(body: Center(child: Text('查無商品資料'))),
            );
          }

          return CupertinoPage(
            child: ProductDetailPage(
              record: record,
              appImages: memoryImages,
            ),
          );
        },
      ),
      GoRoute(
        path: '/product/detail',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final record = extra?['record'] as ProductLensRecord?;
          final memoryImages = (extra?['memoryImages'] ?? extra?['appImages']) as List<AppImageEntity>?;

          if (record == null) {
            return const CupertinoPage(
              child: Scaffold(body: Center(child: Text('查無商品資料'))),
            );
          }

          return CupertinoPage(
            child: ProductDetailPage(
              record: record,
              appImages: memoryImages,
            ),
          );
        },
      ),
      
      // Global Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/settings/ai',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) => const CupertinoPage(
          child: AiSettingsScreen(),
        ),
      ),

      // Result Pages
      GoRoute(
        path: '/result/receipt',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final record = extra?['record'] as ReceiptScannerRecord?;
          final memoryImages = extra?['memoryImages'] as List<AppImageEntity>?;

          if (record == null) {
            return const CupertinoPage(
              child: Scaffold(body: Center(child: Text('查無收據資料'))),
            );
          }
          
          return CupertinoPage(
            child: ReceiptResultPage(
              record: record,
              memoryImages: memoryImages,
            ),
          );
        },
      ),
      GoRoute(
        path: '/process/receipt',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final images = state.extra as List<AppImageEntity>? ?? [];
          return CupertinoPage(
            child: ReceiptProcessingPage(memoryImages: images),
          );
        },
      ),
      GoRoute(
        path: '/process/comparison',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final images = state.extra as List<AppImageEntity>? ?? [];
          return CupertinoPage(
            child: ComparisonProcessingPage(memoryImages: images),
          );
        },
      ),
      GoRoute(
        path: '/result/comparison',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ProductComparisonRecordArgs;
          return CupertinoPage(
            child: ProductComparisonRecordPage(args: args),
          );
        },
      ),
      GoRoute(
        path: '/process/menu',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final images = state.extra as List<AppImageEntity>? ?? [];
          return CupertinoPage(
            child: MenuProcessingPage(memoryImages: images),
          );
        },
      ),
      GoRoute(
        path: '/result/menu',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final record = extra?['record'] as MenuScannerRecord?;
          final memoryImages = extra?['memoryImages'] as List<AppImageEntity>?;

          if (record == null) {
            return const CupertinoPage(
              child: Scaffold(body: Center(child: Text('查無菜單資料'))),
            );
          }
          
          return CupertinoPage(
            child: MenuResultPage(
              record: record,
              memoryImages: memoryImages,
            ),
          );
        },
      ),

      // History Pages
      GoRoute(
        path: '/history',
        parentNavigatorKey: globalNavigatorKey,
        pageBuilder: (context, state) {
          final tabIndexStr = state.uri.queryParameters['tab'];
          final initialIndex = tabIndexStr != null ? int.tryParse(tabIndexStr) ?? 0 : 0;
          return CupertinoPage(
            child: UnifiedHistoryPage(initialTabIndex: initialIndex, configs: defaultHistoryConfigs),
          );
        },
      ),
    ],
  );
});
