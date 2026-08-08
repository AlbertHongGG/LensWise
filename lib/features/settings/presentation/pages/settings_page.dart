import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/glass_container.dart';
import 'package:lens_wise/features/settings/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final languages = ['繁體中文 (Traditional Chinese)', 'English', '日本語 (Japanese)', '한국어 (Korean)'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('偏好設定', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'AI 翻譯與解析設定',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          GlassContainer(
            borderRadius: BorderRadius.circular(16),
            opacity: 0.1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: settingsState.targetLanguage,
                  dropdownColor: const Color(0xFF1E1E1E),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      ref.read(settingsProvider.notifier).updateTargetLanguage(newValue);
                    }
                  },
                  items: languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '不論在國外掃描哪種語言的標籤或收據，AI 都會將結果轉換為您選擇的目標語言。',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
