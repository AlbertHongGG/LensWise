import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_wise/core/providers/shared_prefs_provider.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/main.dart';

class MockSettingsNotifier extends SettingsNotifier {
  @override
  SettingsState build() {
    return const SettingsState(
      targetLanguage: TargetLanguage.traditionalChinese,
      themeMode: ThemeMode.system,
      enableNotificationLog: true,
      enableAiLog: true,
    );
  }
}

void main() {
  testWidgets('App smoke test - MyApp builds MaterialApp.router', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          settingsProvider.overrideWith(MockSettingsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
