import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lens_wise/core/di/app_provider_observer.dart';
import 'package:lens_wise/core/router/app_router.dart';
import 'package:lens_wise/core/theme/app_theme.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ReceiptRecordAdapter());
  Hive.registerAdapter(ProductRecordAdapter());
  Hive.registerAdapter(ComparisonRecordAdapter());
  
  await Hive.openBox('settings');

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
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
    );
  }
}
