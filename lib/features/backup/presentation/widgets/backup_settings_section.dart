import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/backup/presentation/controllers/backup_controller.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_section.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_tile.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
class BackupSettingsSection extends ConsumerWidget {
  const BackupSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsSection(
      title: '資料備份與還原',
      children: [
        SettingsTile(
          icon: Icons.upload_file_rounded,
          iconColor: Theme.of(context).primaryColor,
          title: '匯出歷史紀錄',
          subtitle: '打包為 ZIP 檔',
          onTap: () async {
            final controller = ref.read(backupControllerProvider.notifier);
            ref.read(notificationProvider.notifier).showInfo('正在準備匯出檔案，請稍候...');
            final result = await controller.exportBackup();
            if (context.mounted) {
              if (result == BackupResult.success) {
                ref.read(notificationProvider.notifier).showSuccess('備份檔案已成功匯出至指定位置！');
              } else if (result == BackupResult.error) {
                ref.read(notificationProvider.notifier).showError('匯出失敗，請重試');
              }
              // If canceled, do nothing
            }
          },
        ),
        SettingsTile(
          icon: Icons.settings_backup_restore_rounded,
          iconColor: Theme.of(context).primaryColor,
          title: '匯入歷史紀錄',
          subtitle: '從 ZIP 檔還原',
          onTap: () async {
            final controller = ref.read(backupControllerProvider.notifier);
            final result = await controller.importBackup();
            if (context.mounted) {
              if (result.$1 == BackupResult.success) {
                ref.read(notificationProvider.notifier).showSuccess('資料已成功還原！');
              } else if (result.$1 == BackupResult.error) {
                ref.read(notificationProvider.notifier).showError('匯入失敗：${result.$2 ?? "未知錯誤"}');
              }
              // If canceled, do nothing
            }
          },
        ),
      ],
    );
  }
}
