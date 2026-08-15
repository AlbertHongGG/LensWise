import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/features/backup/presentation/controllers/backup_controller.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_section.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_tile.dart';
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('正在準備匯出檔案，請稍候...')),
            );
            final success = await controller.exportBackup();
            if (context.mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '備份檔案已成功建立！請選擇儲存位置' : '匯出失敗，請重試'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
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
            final success = await controller.importBackup();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '資料已成功還原！' : '匯入已取消或發生錯誤'),
                  backgroundColor: success ? Colors.green : Colors.orange,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
