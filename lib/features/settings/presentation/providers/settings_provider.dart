import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final String targetLanguage;
  final ThemeMode themeMode;

  const SettingsState({
    required this.targetLanguage,
    required this.themeMode,
  });

  SettingsState copyWith({
    String? targetLanguage,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      targetLanguage: targetLanguage ?? this.targetLanguage,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late Box _settingsBox;

  @override
  SettingsState build() {
    _settingsBox = Hive.box('settings');
    final lang = _settingsBox.get('targetLanguage', defaultValue: '繁體中文 (Traditional Chinese)') as String;
    
    // Default to Light mode as requested
    final themeIndex = _settingsBox.get('themeMode', defaultValue: ThemeMode.light.index) as int;
    final theme = ThemeMode.values.firstWhere((e) => e.index == themeIndex, orElse: () => ThemeMode.light);

    return SettingsState(targetLanguage: lang, themeMode: theme);
  }

  void updateTargetLanguage(String language) {
    _settingsBox.put('targetLanguage', language);
    state = state.copyWith(targetLanguage: language);
  }

  void updateThemeMode(ThemeMode mode) {
    _settingsBox.put('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
