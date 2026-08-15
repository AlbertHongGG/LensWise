import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/backup/infrastructure/services/backup_service.dart';
import 'package:lens_wise/core/storage/history_providers.dart';

enum BackupResult { success, canceled, error }

class BackupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<BackupResult> exportBackup() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final resultPath = await service.exportBackup();
      state = const AsyncData(null);
      return resultPath != null ? BackupResult.success : BackupResult.error;
    } catch (e, st) {
      state = AsyncError(e, st);
      if (e.toString().contains('User canceled')) {
        return BackupResult.canceled;
      }
      return BackupResult.error;
    }
  }

  Future<(BackupResult, String?)> importBackup() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      await service.importBackup();
      
      // Invalidate UI state so it re-fetches from repositories
      ref.invalidate(receiptHistoryProvider);
      ref.invalidate(productHistoryProvider);
      ref.invalidate(comparisonHistoryProvider);
      ref.invalidate(menuHistoryProvider);

      state = const AsyncData(null);
      return (BackupResult.success, null);
    } catch (e, st) {
      state = AsyncError(e, st);
      final errorStr = e.toString();
      if (errorStr.contains('User canceled')) {
        return (BackupResult.canceled, null);
      }
      return (BackupResult.error, errorStr.replaceAll('Exception: ', ''));
    }
  }
}

final backupControllerProvider = NotifierProvider<BackupController, AsyncValue<void>>(
  BackupController.new,
);
