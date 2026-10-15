import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/notifications/infrastructure/notification_logger.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';

final notificationLoggerProvider = Provider<NotificationLogger>((ref) {
  return NotificationLogger(
    isEnabled: () => ref.read(settingsProvider).enableNotificationLog,
  );
});

final systemLogListProvider = FutureProvider.autoDispose<List<FileSystemEntity>>(
  (ref) async {
    final logger = ref.watch(notificationLoggerProvider);
    return await logger.getLogs();
  },
);

class SystemLogManager {
  final NotificationLogger _logger;

  SystemLogManager(this._logger);

  Future<void> clearAllLogs() async {
    try {
      final logs = await _logger.getLogs();
      for (var file in logs) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('[SystemLogManager] Failed to clear all logs: $e');
    }
  }

  Future<void> clearLog(FileSystemEntity file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('[SystemLogManager] Failed to clear log: $e');
    }
  }
}

final systemLogManagerProvider = Provider<SystemLogManager>((ref) {
  final logger = ref.watch(notificationLoggerProvider);
  return SystemLogManager(logger);
});
