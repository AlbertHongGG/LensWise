import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';

class AgentAIConfig {
  final AIProviderType activeProviderType;
  final Map<AIProviderType, AIProviderConfig> providerConfigs;

  AgentAIConfig({
    required this.activeProviderType,
    required this.providerConfigs,
  });

  AIProviderConfig get activeConfig => providerConfigs[activeProviderType]!;

  AgentAIConfig copyWith({
    AIProviderType? activeProviderType,
    Map<AIProviderType, AIProviderConfig>? providerConfigs,
  }) {
    return AgentAIConfig(
      activeProviderType: activeProviderType ?? this.activeProviderType,
      providerConfigs: providerConfigs ?? this.providerConfigs,
    );
  }

  AgentAIConfig getEffectiveConfig(Map<AIProviderType, AIProviderConfig> globalConfigs) {
    final effectiveConfigs = <AIProviderType, AIProviderConfig>{};
    for (final entry in providerConfigs.entries) {
      final type = entry.key;
      final overrideConfig = entry.value;
      final globalConfig = globalConfigs[type];
      if (globalConfig != null) {
        effectiveConfigs[type] = overrideConfig.fallbackTo(globalConfig);
      } else {
        effectiveConfigs[type] = overrideConfig;
      }
    }
    return AgentAIConfig(
      activeProviderType: activeProviderType,
      providerConfigs: effectiveConfigs,
    );
  }

  factory AgentAIConfig.defaultConfig() {
    return AgentAIConfig(
      activeProviderType: AIProviderType.geminiflow,
      providerConfigs: {
        AIProviderType.geminiflow: const GeminiFlowConfig.empty(),
        AIProviderType.ollama: const OllamaConfig.empty(),
        AIProviderType.vertexai: const VertexAIConfig.empty(),
      },
    );
  }
}
