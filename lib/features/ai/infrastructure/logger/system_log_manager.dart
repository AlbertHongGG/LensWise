import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/system_logger.dart';
import 'package:lens_wise/features/ai/infrastructure/logger/ai_agent_logger.dart';

class SystemLogManager {
  Future<void> clearAllLogs() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/.runtime/log');

      if (await logDir.exists()) {
        await logDir.delete(recursive: true);
      }
    } catch (e) {
      print('[SystemLogManager] Failed to clear all logs: $e');
    }
  }
}

final systemLogManagerProvider = Provider<SystemLogManager>((ref) {
  return SystemLogManager();
});

final systemLoggerProvider = Provider<SystemLogger>((ref) {
  return SystemLogger();
});

final systemLogListProvider = FutureProvider.autoDispose<List<FileSystemEntity>>(
  (ref) async {
    final logger = ref.watch(systemLoggerProvider);
    return await logger.getLogs();
  },
);

final agentLogListProvider = FutureProvider.autoDispose<List<FileSystemEntity>>(
  (ref) async {
    final logger = AIAgentLogger();
    return await logger.getLogs();
  },
);
