import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_provider_config.dart';
import '../../presentation/controllers/ai_config_controller.dart';
import 'ai_provider.dart';
import 'geminiflow/geminiflow_provider.dart';
import 'ollama/ollama_provider.dart';
import 'vertexai/vertexai_provider.dart';

class ProviderFactory {
  static AIProvider createProvider(AIProviderConfig config) {
    if (config is GeminiFlowConfig) {
      if (config.baseUrl.isEmpty) {
        throw Exception('[ERROR] GeminiFlow Base URL is missing.');
      }
      return GeminiFlowProvider(
        baseUrl: config.baseUrl,
        modelName: config.modelName,
      );
    } else if (config is OllamaConfig) {
      if (config.baseUrl.isEmpty) {
        throw Exception('[ERROR] Ollama Base URL is missing.');
      }
      return OllamaProvider(
        baseUrl: config.baseUrl,
        modelName: config.modelName,
      );
    } else if (config is VertexAIConfig) {
      if (config.projectId.isEmpty || config.accessToken.isEmpty) {
        throw Exception(
          '[ERROR] Vertex AI Project ID or Access Token is missing.',
        );
      }
      return VertexAIProvider(
        projectId: config.projectId,
        region: config.region,
        accessToken: config.accessToken,
        modelName: config.modelName,
      );
    }

    throw UnsupportedError(
      '[ERROR] Unsupported AIProviderConfig type: ${config.runtimeType}',
    );
  }
}

final aiProviderProvider = Provider.autoDispose<AIProvider>((ref) {
  final state = ref.watch(aiConfigControllerProvider);
  return ProviderFactory.createProvider(state.activeConfig);
});
