import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsState {
  final String targetLanguage;

  const SettingsState({
    required this.targetLanguage,
  });

  SettingsState copyWith({
    String? targetLanguage,
  }) {
    return SettingsState(
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late Box _settingsBox;

  @override
  SettingsState build() {
    _settingsBox = Hive.box('settings');
    final lang = _settingsBox.get('targetLanguage', defaultValue: '繁體中文 (Traditional Chinese)') as String;
    return SettingsState(targetLanguage: lang);
  }

  void updateTargetLanguage(String language) {
    _settingsBox.put('targetLanguage', language);
    state = state.copyWith(targetLanguage: language);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
