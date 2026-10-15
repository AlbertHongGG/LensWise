import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lens_wise/core/models/target_language.dart';

class SettingsState {
  final TargetLanguage targetLanguage;
  final ThemeMode themeMode;
  final bool enableNotificationLog;
  final bool enableAiLog;

  const SettingsState({
    required this.targetLanguage,
    required this.themeMode,
    required this.enableNotificationLog,
    required this.enableAiLog,
  });

  SettingsState copyWith({
    TargetLanguage? targetLanguage,
    ThemeMode? themeMode,
    bool? enableNotificationLog,
    bool? enableAiLog,
  }) {
    return SettingsState(
      targetLanguage: targetLanguage ?? this.targetLanguage,
      themeMode: themeMode ?? this.themeMode,
      enableNotificationLog: enableNotificationLog ?? this.enableNotificationLog,
      enableAiLog: enableAiLog ?? this.enableAiLog,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late Box _settingsBox;

  @override
  SettingsState build() {
    _settingsBox = Hive.box('settings');
    final langStr = _settingsBox.get('targetLanguage', defaultValue: TargetLanguage.traditionalChinese.name) as String;
    final lang = TargetLanguage.fromString(langStr);
    
    // Default to Light mode as requested
    final themeIndex = _settingsBox.get('themeMode', defaultValue: ThemeMode.light.index) as int;
    final theme = ThemeMode.values.firstWhere((e) => e.index == themeIndex, orElse: () => ThemeMode.light);

    final notificationLog = _settingsBox.get('enableNotificationLog', defaultValue: true) as bool;
    final aiLog = _settingsBox.get('enableAiLog', defaultValue: true) as bool;

    return SettingsState(
      targetLanguage: lang,
      themeMode: theme,
      enableNotificationLog: notificationLog,
      enableAiLog: aiLog,
    );
  }

  void updateTargetLanguage(TargetLanguage language) {
    _settingsBox.put('targetLanguage', language.name);
    state = state.copyWith(targetLanguage: language);
  }

  void updateThemeMode(ThemeMode mode) {
    _settingsBox.put('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void toggleNotificationLog(bool value) {
    _settingsBox.put('enableNotificationLog', value);
    state = state.copyWith(enableNotificationLog: value);
  }

  void toggleAiLog(bool value) {
    _settingsBox.put('enableAiLog', value);
    state = state.copyWith(enableAiLog: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
