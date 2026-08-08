import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_section.dart';
import 'package:lens_wise/features/settings/presentation/widgets/settings_tile.dart';
import 'package:lens_wise/core/widgets/pickers/string_wheel_picker.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/core/widgets/premium_config_header.dart';
import 'package:lens_wise/core/widgets/app_switch.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final languages = ['繁體中文', 'English', '日本語', '한국어'];

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
                iconColor: Colors.deepPurpleAccent,
                title: '深色模式 (Dark Mode)',
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
            title: 'AI 跨境解析',
            children: [
              SettingsTile(
                icon: Icons.language_rounded,
                iconColor: Colors.blueAccent,
                title: '目標翻譯語言',
                subtitle: settingsState.targetLanguage,
                onTap: () async {
                  final initialIndex = languages.indexOf(settingsState.targetLanguage);
                  final selectedIndex = await showCustomWheelPicker(
                    context: context,
                    title: '目標翻譯語言',
                    items: languages,
                    initialIndex: initialIndex != -1 ? initialIndex : 0,
                  );
                  if (selectedIndex != null) {
                    notifier.updateTargetLanguage(languages[selectedIndex]);
                  }
                },
              ),
            ],
          ),
          SettingsSection(
            title: 'AI 引擎與進階設定',
            children: [
              SettingsTile(
                icon: Icons.smart_toy_rounded,
                iconColor: Colors.purpleAccent,
                title: 'AI 引擎與 API 設定 (Engine Configuration)',
                onTap: () {
                  context.push('/settings/ai');
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
