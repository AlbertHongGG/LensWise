import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_wise/core/di/app_provider_observer.dart';
import 'package:lens_wise/core/providers/shared_prefs_provider.dart';
import 'package:lens_wise/core/router/app_router.dart';
import 'package:lens_wise/core/theme/app_theme.dart';
import 'package:lens_wise/core/notifications/presentation/widgets/global_notification_overlay.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/receipt_scanner/infrastructure/models/receipt_scanner_hive_model.dart';
import 'package:lens_wise/features/product_lens/infrastructure/models/product_lens_hive_model.dart';
import 'package:lens_wise/features/product_comparison/infrastructure/models/product_comparison_hive_model.dart';
import 'package:lens_wise/features/menu_scanner/infrastructure/models/menu_scanner_hive_model.dart';

import 'package:lens_wise/core/di/hardware_providers.dart';
import 'package:lens_wise/core/services/camerawesome_service.dart';
import 'package:lens_wise/core/services/photo_manager_gallery_service.dart';
import 'package:lens_wise/core/services/image_picker_service.dart';
import 'package:lens_wise/core/utils/app_paths.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppPaths.init();
  await Hive.initFlutter();
  Hive.registerAdapter(ReceiptScannerHiveModelAdapter());
  Hive.registerAdapter(ProductLensHiveModelAdapter());
  Hive.registerAdapter(ProductComparisonHiveModelAdapter());
  Hive.registerAdapter(MenuScannerHiveModelAdapter());
  
  await Hive.openBox('settings');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        cameraServiceProvider.overrideWith((ref) => CamerawesomeService()),
        galleryServiceProvider.overrideWith((ref) => PhotoManagerGalleryService()),
        imagePickerServiceProvider.overrideWith((ref) => ImagePickerService(ref)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp.router(
      title: 'LensWise',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return GlobalNotificationOverlay(child: child!);
      },
    );
  }
}
