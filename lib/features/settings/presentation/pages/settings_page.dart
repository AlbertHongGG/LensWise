import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_section.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_tile.dart';
import 'package:lens_wise/core/widgets/pickers/string_wheel_picker.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/core/widgets/premium_config_header.dart';
import 'package:lens_wise/core/widgets/app_switch.dart';
import 'package:lens_wise/features/ai/presentation/screens/ai_log_viewer_screen.dart';
import 'package:lens_wise/core/notifications/presentation/screens/system_log_viewer_screen.dart';
import 'package:lens_wise/core/models/target_language.dart';
import 'package:lens_wise/features/backup/presentation/widgets/backup_settings_section.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final languages = TargetLanguage.values.map((e) => e.displayName).toList();

    return ImmersiveScaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const PremiumConfigHeader(
            title: '偏好設定',
            subtitle: 'SYSTEM CONFIGURATION',
          ),
          SettingsSection(
            title: '外觀與系統',
            children: [
              SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: AppColors.primary,
                title: '深色模式',
                trailing: AppSwitch(
                  value: settingsState.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    notifier.updateThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
            ],
          ),
          SettingsSection(
            title: 'AI 解析與引擎設定',
            children: [
              SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.primary,
                title: '目標翻譯語言',
                subtitle: settingsState.targetLanguage.displayName,
                onTap: () async {
                  final initialIndex = TargetLanguage.values.indexOf(settingsState.targetLanguage);
                  final selectedIndex = await showCustomWheelPicker(
                    context: context,
                    title: '目標翻譯語言',
                    items: languages,
                    initialIndex: initialIndex != -1 ? initialIndex : 0,
                  );
                  if (selectedIndex != null) {
                    notifier.updateTargetLanguage(TargetLanguage.values[selectedIndex]);
                  }
                },
              ),
              SettingsTile(
                icon: Icons.smart_toy_rounded,
                iconColor: AppColors.primary,
                title: 'API 與引擎設定',
                onTap: () {
                  context.push('/settings/ai');
                },
              ),
              SettingsTile(
                icon: Icons.data_object_rounded,
                iconColor: AppColors.primary,
                title: 'AI 解析日誌',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiLogViewerScreen()),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.history_rounded,
                iconColor: AppColors.primary,
                title: 'APP 系統通知日誌',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SystemLogViewerScreen()),
                  );
                },
              ),
            ],
          ),
          
          const BackupSettingsSection(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
