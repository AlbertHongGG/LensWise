abstract class AIProviderConfig {
  const AIProviderConfig();
}

class GeminiFlowConfig extends AIProviderConfig {
  final String baseUrl;
  final String modelName;

  const GeminiFlowConfig({
    required this.baseUrl,
    this.modelName = 'gemini-3.6-flash',
  });
}

class OllamaConfig extends AIProviderConfig {
  final String baseUrl;
  final String modelName;

  const OllamaConfig({
    required this.baseUrl,
    required this.modelName,
  });
}

class VertexAIConfig extends AIProviderConfig {
  final String projectId;
  final String region;
  final String accessToken;
  final String modelName;

  const VertexAIConfig({
    required this.projectId,
    required this.region,
    required this.accessToken,
    required this.modelName,
  });
}
