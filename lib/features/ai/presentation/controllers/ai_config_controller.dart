import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/domain/models/ai_agent_type.dart';
import 'package:lens_wise/features/ai/domain/models/agent_ai_config.dart';
import 'package:lens_wise/core/providers/shared_prefs_provider.dart';

class AIConfigState {
  final Map<AIProviderType, AIProviderConfig> globalProviderConfigs;
  final AIProviderType editingGlobalProviderType;
  final Map<AiAgentType, AgentAIConfig> agentConfigs;
  final bool isAIAgentEnabled;

  AIConfigState({
    required this.globalProviderConfigs,
    this.editingGlobalProviderType = AIProviderType.geminiflow,
    required this.agentConfigs,
    this.isAIAgentEnabled = true,
  });

  AgentAIConfig getOverrideConfigFor(AiAgentType agentType) {
    return agentConfigs[agentType] ?? AgentAIConfig.defaultConfig();
  }

  AgentAIConfig getEffectiveConfigFor(AiAgentType agentType) {
    return getOverrideConfigFor(agentType).getEffectiveConfig(globalProviderConfigs);
  }

  AIProviderConfig get editingGlobalConfig => globalProviderConfigs[editingGlobalProviderType]!;

  AIConfigState copyWith({
    Map<AIProviderType, AIProviderConfig>? globalProviderConfigs,
    AIProviderType? editingGlobalProviderType,
    Map<AiAgentType, AgentAIConfig>? agentConfigs,
    bool? isAIAgentEnabled,
  }) {
    return AIConfigState(
      globalProviderConfigs: globalProviderConfigs ?? this.globalProviderConfigs,
      editingGlobalProviderType: editingGlobalProviderType ?? this.editingGlobalProviderType,
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

    final Map<AIProviderType, AIProviderConfig> globalConfigs = {
      AIProviderType.geminiflow: const GeminiFlowConfig(),
      AIProviderType.ollama: const OllamaConfig(),
      AIProviderType.vertexai: const VertexAIConfig(),
    };

    final globalGeminiflowJson = prefs.getString('ai_global_config_geminiflow');
    if (globalGeminiflowJson != null) {
      globalConfigs[AIProviderType.geminiflow] = GeminiFlowConfig.fromJson(jsonDecode(globalGeminiflowJson));
    }

    final globalOllamaJson = prefs.getString('ai_global_config_ollama');
    if (globalOllamaJson != null) {
      globalConfigs[AIProviderType.ollama] = OllamaConfig.fromJson(jsonDecode(globalOllamaJson));
    }

    final globalVertexaiJson = prefs.getString('ai_global_config_vertexai');
    if (globalVertexaiJson != null) {
      globalConfigs[AIProviderType.vertexai] = VertexAIConfig.fromJson(jsonDecode(globalVertexaiJson));
    }

    final editingGlobalTypeStr = prefs.getString('ai_global_editing_provider');
    final editingGlobalType = editingGlobalTypeStr != null
        ? AIProviderType.values.byName(editingGlobalTypeStr)
        : AIProviderType.geminiflow;

    final Map<AiAgentType, AgentAIConfig> loadedConfigs = {};

    for (final agentType in AiAgentType.values) {
      final prefix = 'ai_agent_${agentType.name}';
      
      final typeStr = prefs.getString('${prefix}_provider_type');
      final activeType = typeStr != null
          ? AIProviderType.values.byName(typeStr)
          : AIProviderType.geminiflow;

      final Map<AIProviderType, AIProviderConfig> providerConfigs = {
        AIProviderType.geminiflow: const GeminiFlowConfig.empty(),
        AIProviderType.ollama: const OllamaConfig.empty(),
        AIProviderType.vertexai: const VertexAIConfig.empty(),
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
      globalProviderConfigs: globalConfigs,
      editingGlobalProviderType: editingGlobalType,
      agentConfigs: loadedConfigs,
      isAIAgentEnabled: isAIAgentEnabled,
    );
  }

  Future<void> saveGlobalProviderConfig(
    AIProviderType providerType, {
    AIProviderConfig? config,
    bool setAsEditing = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    var newState = state;
    if (setAsEditing) {
      newState = newState.copyWith(editingGlobalProviderType: providerType);
      await prefs.setString('ai_global_editing_provider', providerType.name);
    }

    if (config != null) {
      final newGlobalConfigs = Map<AIProviderType, AIProviderConfig>.from(newState.globalProviderConfigs);
      newGlobalConfigs[providerType] = config;
      newState = newState.copyWith(globalProviderConfigs: newGlobalConfigs);
      
      await prefs.setString(
        'ai_global_config_${providerType.name}',
        jsonEncode(config.toJson()),
      );
    }
    
    state = newState;
  }

  Future<void> saveAgentConfig(
    AiAgentType agentType, {
    AIProviderType? providerType,
    AIProviderConfig? activeProviderConfig,
  }) async {
    final currentAgentConfig = state.getOverrideConfigFor(agentType);
    
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
