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

  factory AgentAIConfig.defaultConfig() {
    return AgentAIConfig(
      activeProviderType: AIProviderType.geminiflow,
      providerConfigs: {
        AIProviderType.geminiflow: const GeminiFlowConfig(),
        AIProviderType.ollama: const OllamaConfig(),
        AIProviderType.vertexai: const VertexAIConfig(),
      },
    );
  }
}
