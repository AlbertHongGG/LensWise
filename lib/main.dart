import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/app_provider_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      child: const LensWiseApp(),
    ),
  );
}

class LensWiseApp extends ConsumerWidget {
  const LensWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'LensWise',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
