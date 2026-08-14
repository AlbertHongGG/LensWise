import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/agent_ai_config.dart';
import 'package:lens_wise/core/providers/shared_prefs_provider.dart';

class AIConfigState {
  final Map<AiAgentType, AgentAIConfig> agentConfigs;
  final bool isAIAgentEnabled;

  AIConfigState({
    required this.agentConfigs,
    this.isAIAgentEnabled = true,
  });

  AgentAIConfig getConfigFor(AiAgentType agentType) {
    return agentConfigs[agentType] ?? AgentAIConfig.defaultConfig();
  }

  AIConfigState copyWith({
    Map<AiAgentType, AgentAIConfig>? agentConfigs,
    bool? isAIAgentEnabled,
  }) {
    return AIConfigState(
      agentConfigs: agentConfigs ?? this.agentConfigs,
      isAIAgentEnabled: isAIAgentEnabled ?? this.isAIAgentEnabled,
    );
  }
}

class AIConfigController extends Notifier<AIConfigState> {
  @override
  AIConfigState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isAIAgentEnabled = prefs.getBool('is_ai_agent_enabled') ?? true;

    final Map<AiAgentType, AgentAIConfig> loadedConfigs = {};

    for (final agentType in AiAgentType.values) {
      final prefix = 'ai_agent_${agentType.name}';
      
      final typeStr = prefs.getString('${prefix}_provider_type');
      final activeType = typeStr != null
          ? AIProviderType.values.byName(typeStr)
          : AIProviderType.geminiflow;

      final Map<AIProviderType, AIProviderConfig> providerConfigs = {
        AIProviderType.geminiflow: const GeminiFlowConfig(),
        AIProviderType.ollama: const OllamaConfig(),
        AIProviderType.vertexai: const VertexAIConfig(),
      };

      final geminiflowJson = prefs.getString('${prefix}_config_geminiflow');
      if (geminiflowJson != null) {
        providerConfigs[AIProviderType.geminiflow] = GeminiFlowConfig.fromJson(jsonDecode(geminiflowJson));
      }

      final ollamaJson = prefs.getString('${prefix}_config_ollama');
      if (ollamaJson != null) {
        providerConfigs[AIProviderType.ollama] = OllamaConfig.fromJson(jsonDecode(ollamaJson));
      }

      final vertexaiJson = prefs.getString('${prefix}_config_vertexai');
      if (vertexaiJson != null) {
        providerConfigs[AIProviderType.vertexai] = VertexAIConfig.fromJson(jsonDecode(vertexaiJson));
      }

      loadedConfigs[agentType] = AgentAIConfig(
        activeProviderType: activeType,
        providerConfigs: providerConfigs,
      );
    }

    return AIConfigState(
      agentConfigs: loadedConfigs,
      isAIAgentEnabled: isAIAgentEnabled,
    );
  }

  Future<void> saveAgentConfig(
    AiAgentType agentType, {
    AIProviderType? providerType,
    AIProviderConfig? activeProviderConfig,
  }) async {
    final currentAgentConfig = state.getConfigFor(agentType);
    
    final newProviderConfigs = Map<AIProviderType, AIProviderConfig>.from(
      currentAgentConfig.providerConfigs,
    );

    if (activeProviderConfig != null) {
      final targetType = providerType ?? currentAgentConfig.activeProviderType;
      newProviderConfigs[targetType] = activeProviderConfig;
    }

    final newAgentConfig = currentAgentConfig.copyWith(
      activeProviderType: providerType,
      providerConfigs: newProviderConfigs,
    );

    final newAgentConfigsMap = Map<AiAgentType, AgentAIConfig>.from(state.agentConfigs);
    newAgentConfigsMap[agentType] = newAgentConfig;

    state = state.copyWith(agentConfigs: newAgentConfigsMap);

    final prefs = await SharedPreferences.getInstance();
    final prefix = 'ai_agent_${agentType.name}';

    await prefs.setString('${prefix}_provider_type', newAgentConfig.activeProviderType.name);

    await prefs.setString(
      '${prefix}_config_geminiflow',
      jsonEncode(newAgentConfig.providerConfigs[AIProviderType.geminiflow]!.toJson()),
    );
    await prefs.setString(
      '${prefix}_config_ollama',
      jsonEncode(newAgentConfig.providerConfigs[AIProviderType.ollama]!.toJson()),
    );
    await prefs.setString(
      '${prefix}_config_vertexai',
      jsonEncode(newAgentConfig.providerConfigs[AIProviderType.vertexai]!.toJson()),
    );
  }

  Future<void> setAIAgentEnabled(bool isEnabled) async {
    state = state.copyWith(isAIAgentEnabled: isEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_ai_agent_enabled', isEnabled);
  }
}

final aiConfigControllerProvider =
    NotifierProvider<AIConfigController, AIConfigState>(AIConfigController.new);
