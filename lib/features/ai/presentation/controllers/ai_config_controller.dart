import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';

import 'package:lens_wise/core/providers/shared_prefs_provider.dart';

class AIConfigState {
  final AIProviderType providerType;
  final Map<AIProviderType, AIProviderConfig> configs;
  final bool isAIAgentEnabled;

  AIConfigState({
    this.providerType = AIProviderType.geminiflow,
    Map<AIProviderType, AIProviderConfig>? configs,
    this.isAIAgentEnabled = true,
  }) : configs =
           configs ??
           {
             AIProviderType.geminiflow: const GeminiFlowConfig(),
             AIProviderType.ollama: const OllamaConfig(),
             AIProviderType.vertexai: const VertexAIConfig(),
           };

  AIProviderConfig get activeConfig => configs[providerType]!;

  AIConfigState copyWith({
    AIProviderType? providerType,
    Map<AIProviderType, AIProviderConfig>? configs,
    bool? isAIAgentEnabled,
  }) {
    return AIConfigState(
      providerType: providerType ?? this.providerType,
      configs: configs ?? this.configs,
      isAIAgentEnabled: isAIAgentEnabled ?? this.isAIAgentEnabled,
    );
  }
}

class AIConfigController extends Notifier<AIConfigState> {
  @override
  AIConfigState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final typeStr = prefs.getString('ai_provider_type');
    final type = typeStr != null
        ? AIProviderType.values.byName(typeStr)
        : AIProviderType.geminiflow;

    final Map<AIProviderType, AIProviderConfig> loadedConfigs = {
      AIProviderType.geminiflow: const GeminiFlowConfig(),
      AIProviderType.ollama: const OllamaConfig(),
      AIProviderType.vertexai: const VertexAIConfig(),
    };

    final geminiflowJson = prefs.getString('ai_config_geminiflow');
    if (geminiflowJson != null)
      loadedConfigs[AIProviderType.geminiflow] = GeminiFlowConfig.fromJson(
        jsonDecode(geminiflowJson),
      );

    final ollamaJson = prefs.getString('ai_config_ollama');
    if (ollamaJson != null)
      loadedConfigs[AIProviderType.ollama] = OllamaConfig.fromJson(
        jsonDecode(ollamaJson),
      );

    final vertexaiJson = prefs.getString('ai_config_vertexai');
    if (vertexaiJson != null)
      loadedConfigs[AIProviderType.vertexai] = VertexAIConfig.fromJson(
        jsonDecode(vertexaiJson),
      );

    final isAIAgentEnabled = prefs.getBool('is_ai_agent_enabled') ?? true;

    return AIConfigState(
      providerType: type,
      configs: loadedConfigs,
      isAIAgentEnabled: isAIAgentEnabled,
    );
  }

  Future<void> saveConfig({
    AIProviderType? providerType,
    AIProviderConfig? activeProviderConfig,
    bool? isAIAgentEnabled,
  }) async {
    final newConfigs = Map<AIProviderType, AIProviderConfig>.from(
      state.configs,
    );

    if (activeProviderConfig != null) {
      newConfigs[providerType ?? state.providerType] = activeProviderConfig;
    }

    state = state.copyWith(
      providerType: providerType,
      configs: newConfigs,
      isAIAgentEnabled: isAIAgentEnabled,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_provider_type', state.providerType.name);

    await prefs.setString(
      'ai_config_geminiflow',
      jsonEncode(state.configs[AIProviderType.geminiflow]!.toJson()),
    );
    await prefs.setString(
      'ai_config_ollama',
      jsonEncode(state.configs[AIProviderType.ollama]!.toJson()),
    );
    await prefs.setString(
      'ai_config_vertexai',
      jsonEncode(state.configs[AIProviderType.vertexai]!.toJson()),
    );

    if (isAIAgentEnabled != null) {
      await prefs.setBool('is_ai_agent_enabled', isAIAgentEnabled);
    }
  }
}

final aiConfigControllerProvider =
    NotifierProvider<AIConfigController, AIConfigState>(AIConfigController.new);
