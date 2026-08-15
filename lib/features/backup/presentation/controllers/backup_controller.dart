import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/backup/infrastructure/services/backup_service.dart';

class BackupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> exportBackup() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final resultPath = await service.exportBackup();
      state = const AsyncData(null);
      return resultPath != null;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> importBackup() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.importBackup();
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final backupControllerProvider = NotifierProvider<BackupController, AsyncValue<void>>(
  BackupController.new,
);
