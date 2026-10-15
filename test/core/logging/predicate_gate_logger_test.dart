import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';

void main() {
  group('SettingsState & Logging Toggle Tests', () {
    test('SettingsState defaults and copyWith preserve logging flags', () {
      const state = SettingsState(
        targetLanguage: TargetLanguage.traditionalChinese,
        themeMode: ThemeMode.light,
        enableNotificationLog: true,
        enableAiLog: true,
      );

      expect(state.enableNotificationLog, isTrue);
      expect(state.enableAiLog, isTrue);

      final modified = state.copyWith(
        enableNotificationLog: false,
        enableAiLog: false,
      );

      expect(modified.enableNotificationLog, isFalse);
      expect(modified.enableAiLog, isFalse);
      expect(modified.targetLanguage, TargetLanguage.traditionalChinese);
    });

    test('Predicate Gate simulation blocks logging when disabled', () {
      bool isNotificationLogEnabled = false;
      bool isAiLogEnabled = false;

      var notificationWritten = false;
      var aiWritten = false;

      // Mock gate logic matching BaseFileLogger.log
      void logNotification(String message) {
        if (!isNotificationLogEnabled) return;
        notificationWritten = true;
      }

      void logAi(dynamic data) {
        if (!isAiLogEnabled) return;
        aiWritten = true;
      }

      // Disabled test
      logNotification('test notification');
      logAi({'prompt': 'test'});

      expect(notificationWritten, isFalse);
      expect(aiWritten, isFalse);

      // Enable and test
      isNotificationLogEnabled = true;
      isAiLogEnabled = true;

      logNotification('test notification');
      logAi({'prompt': 'test'});

      expect(notificationWritten, isTrue);
      expect(aiWritten, isTrue);
    });
  });
}
