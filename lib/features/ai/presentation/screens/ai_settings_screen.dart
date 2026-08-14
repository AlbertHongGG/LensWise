import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:lens_wise/core/theme/app_colors.dart';
import 'package:lens_wise/core/widgets/app_switch.dart';
import 'package:lens_wise/core/widgets/premium_config_header.dart';
import 'package:lens_wise/core/widgets/immersive_scaffold.dart';

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
                      'GLOBAL SETTINGS',
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
                    child: Column(
                      children: AiAgentType.values
                          .map((agentType) {
                        final agentConfig = state.getConfigFor(agentType);
                        final activeProvider = agentConfig.activeProviderType;
                        final isLast = agentType == AiAgentType.values.last;
                        
                        return Column(
                          children: [
                            ListTile(
                              enabled: state.isAIAgentEnabled,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${activeProvider.name.toUpperCase()} • ${agentConfig.activeConfig.modelName}',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white30 : Colors.black26),
                              onTap: () {
                                context.push('/agent_config/${agentType.name}');
                              },
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
