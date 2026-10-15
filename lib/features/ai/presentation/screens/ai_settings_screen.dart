import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/app_switch.dart';
import 'package:lens_wise/core/widgets/premium_config_header.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';
import 'package:lens_wise/features/ai/presentation/widgets/config_field_tile.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  IconData _getProviderIcon(AIProviderType type) {
    if (type == AIProviderType.geminiflow) return Icons.auto_awesome;
    if (type == AIProviderType.ollama) return Icons.memory_rounded;
    return Icons.cloud_done_rounded;
  }
  
  IconData _getAgentIcon(AiAgentType type) {
    switch (type) {
      case AiAgentType.aiChat: return Icons.chat_bubble_rounded;
      case AiAgentType.menuScanner: return Icons.document_scanner_rounded;
      case AiAgentType.menuTranslation: return Icons.g_translate_rounded;
      case AiAgentType.productLens: return Icons.center_focus_strong_rounded;
      case AiAgentType.productComparison: return Icons.compare_arrows_rounded;
      case AiAgentType.receiptScanner: return Icons.receipt_long_rounded;
    }
  }

  void _showProviderSelectorBottomSheet(
    BuildContext context, 
    WidgetRef ref, 
    AiAgentType agentType, 
    AIProviderType activeType, 
    bool isDark
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '選擇 AI 引擎',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...AIProviderType.values.map((type) => ListTile(
              onTap: () {
                ref.read(aiConfigControllerProvider.notifier).saveAgentConfig(
                  agentType,
                  providerType: type,
                );
                Navigator.pop(ctx);
              },
              leading: Icon(_getProviderIcon(type), color: Theme.of(context).primaryColor),
              title: Text(type.name.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              trailing: activeType == type ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor) : null,
            )),
          ],
        ),
      ),
    );
  }

  void _showGlobalProviderSelectorBottomSheet(
    BuildContext context, 
    WidgetRef ref, 
    AIProviderType activeType, 
    bool isDark
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '選擇全域 AI 引擎',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...AIProviderType.values.map((type) => ListTile(
              onTap: () {
                ref.read(aiConfigControllerProvider.notifier).saveGlobalProviderConfig(
                  type,
                  setAsEditing: true,
                );
                Navigator.pop(ctx);
              },
              leading: Icon(_getProviderIcon(type), color: Theme.of(context).primaryColor),
              title: Text(type.name.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              trailing: activeType == type ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor) : null,
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiConfigControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ImmersiveScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PremiumConfigHeader(
              title: 'AI 代理調度中心',
              subtitle: 'PER-AGENT INTELLIGENCE ROUTING',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 10, top: 12),
                    child: Text(
                      'SYSTEM STATE',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.power_settings_new_rounded, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 16),
                              Text(
                                '啟用 AI Agent 功能',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          AppSwitch(
                            value: state.isAIAgentEnabled,
                            onChanged: (v) {
                              ref.read(aiConfigControllerProvider.notifier).setAIAgentEnabled(v);
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // GLOBAL PROVIDERS CONFIGURATION
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 10),
                    child: Text(
                      'GLOBAL PROVIDERS CONFIGURATION',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.public_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            '全域供應商設定',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(_getProviderIcon(state.editingGlobalProviderType), size: 12, color: isDark ? Colors.white54 : Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  state.editingGlobalProviderType.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFF4F5F7),
                                border: Border(
                                  top: BorderSide(
                                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                    leading: Icon(_getProviderIcon(state.editingGlobalProviderType), color: isDark ? Colors.white54 : Colors.black54),
                                    title: Text(
                                      state.editingGlobalProviderType.name.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    trailing: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.black54),
                                    onTap: () => _showGlobalProviderSelectorBottomSheet(context, ref, state.editingGlobalProviderType, isDark),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 64),
                                    child: Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  ...state.editingGlobalConfig.getFormFields().asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final field = entry.value;
                                    return Column(
                                      children: [
                                        ConfigFieldTile(
                                          key: ValueKey('global_${state.editingGlobalProviderType.name}_${field.key}'),
                                          activeConfig: state.editingGlobalConfig,
                                          field: field,
                                          isDark: isDark,
                                          onChanged: (val) {
                                            ref.read(aiConfigControllerProvider.notifier).saveGlobalProviderConfig(
                                              state.editingGlobalProviderType,
                                              config: state.editingGlobalConfig.copyWithField(field.key, val),
                                            );
                                          },
                                        ),
                                        if (idx != state.editingGlobalConfig.getFormFields().length - 1)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 64),
                                            child: Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                          ),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 10),
                    child: Text(
                      'AGENT FLEET CONFIGURATION',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: AiAgentType.values
                            .map((agentType) {
                          final agentConfig = state.getOverrideConfigFor(agentType);
                          final activeProvider = agentConfig.activeProviderType;
                          final activeConfig = agentConfig.activeConfig;
                          final globalFallbackConfig = state.globalProviderConfigs[activeProvider];
                          final isLast = agentType == AiAgentType.values.last;
                          
                          return Column(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  enabled: state.isAIAgentEnabled,
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getAgentIcon(agentType),
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    agentType.displayName,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Icon(_getProviderIcon(activeProvider), size: 12, color: isDark ? Colors.white54 : Colors.black54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          activeProvider.name.toUpperCase(),
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white54 : Colors.black54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFF4F5F7),
                                        border: Border(
                                          top: BorderSide(
                                            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                            leading: Icon(_getProviderIcon(activeProvider), color: isDark ? Colors.white54 : Colors.black54),
                                            title: Text(
                                              activeProvider.name.toUpperCase(),
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            trailing: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white54 : Colors.black54),
                                            onTap: () => _showProviderSelectorBottomSheet(context, ref, agentType, activeProvider, isDark),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 64),
                                            child: Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                          ),
                                          ...activeConfig.getFormFields(globalFallbackConfig).asMap().entries.map((entry) {
                                            final idx = entry.key;
                                            final field = entry.value;
                                            return Column(
                                              children: [
                                                ConfigFieldTile(
                                                  key: ValueKey('${agentType.name}_${activeProvider.name}_${field.key}'),
                                                  activeConfig: activeConfig,
                                                  field: field,
                                                  isDark: isDark,
                                                  onChanged: (val) {
                                                    ref.read(aiConfigControllerProvider.notifier).saveAgentConfig(
                                                      agentType,
                                                      activeProviderConfig: activeConfig.copyWithField(field.key, val),
                                                    );
                                                  },
                                                ),
                                                if (idx != activeConfig.getFormFields(globalFallbackConfig).length - 1)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 64),
                                                    child: Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                                  ),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Padding(
                                  padding: const EdgeInsets.only(left: 72),
                                  child: Divider(
                                    height: 1,
                                    thickness: 0.5,
                                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
