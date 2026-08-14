enum AIProviderType { geminiflow, ollama, vertexai }

class ConfigField {
  final String key;
  final String label;
  final String value;
  final bool isSecret;

  const ConfigField({
    required this.key,
    required this.label,
    required this.value,
    this.isSecret = false,
  });
}

abstract class AIProviderConfig {
  final String modelName;

  const AIProviderConfig({required this.modelName});

  Map<String, dynamic> toJson();
  
  List<ConfigField> get formFields;
  
  AIProviderConfig copyWithField(String key, String value);
}

class GeminiFlowConfig extends AIProviderConfig {
  final String baseUrl;

  const GeminiFlowConfig({
    super.modelName = 'gemini-3.6-flash',
    this.baseUrl = 'http://127.0.0.1:8000',
  });

  @override
  Map<String, dynamic> toJson() => {'modelName': modelName, 'baseUrl': baseUrl};

  factory GeminiFlowConfig.fromJson(Map<String, dynamic> json) {
    return GeminiFlowConfig(
      modelName: json['modelName'] ?? 'gemini-3.6-flash',
      baseUrl: json['baseUrl'] ?? 'http://127.0.0.1:8000',
    );
  }

  @override
  List<ConfigField> get formFields => [
    ConfigField(key: 'modelName', label: 'Model Name', value: modelName),
    ConfigField(key: 'baseUrl', label: 'Base URL', value: baseUrl),
  ];

  @override
  AIProviderConfig copyWithField(String key, String value) {
    return GeminiFlowConfig(
      modelName: key == 'modelName' ? value : modelName,
      baseUrl: key == 'baseUrl' ? value : baseUrl,
    );
  }
}

class OllamaConfig extends AIProviderConfig {
  final String baseUrl;

  const OllamaConfig({
    super.modelName = 'llama3',
    this.baseUrl = 'http://localhost:11434',
  });

  @override
  Map<String, dynamic> toJson() => {'modelName': modelName, 'baseUrl': baseUrl};

  factory OllamaConfig.fromJson(Map<String, dynamic> json) {
    return OllamaConfig(
      modelName: json['modelName'] ?? 'llama3',
      baseUrl: json['baseUrl'] ?? 'http://localhost:11434',
    );
  }

  @override
  List<ConfigField> get formFields => [
    ConfigField(key: 'modelName', label: 'Model Name', value: modelName),
    ConfigField(key: 'baseUrl', label: 'Base URL', value: baseUrl),
  ];

  @override
  AIProviderConfig copyWithField(String key, String value) {
    return OllamaConfig(
      modelName: key == 'modelName' ? value : modelName,
      baseUrl: key == 'baseUrl' ? value : baseUrl,
    );
  }
}

class VertexAIConfig extends AIProviderConfig {
  final String projectId;
  final String region;
  final String accessToken;

  const VertexAIConfig({
    super.modelName = 'gemini-1.5-pro-preview-0409',
    this.projectId = '',
    this.region = 'us-central1',
    this.accessToken = '',
  });

  @override
  Map<String, dynamic> toJson() => {
    'modelName': modelName,
    'projectId': projectId,
    'region': region,
    'accessToken': accessToken,
  };

  factory VertexAIConfig.fromJson(Map<String, dynamic> json) {
    return VertexAIConfig(
      modelName: json['modelName'] ?? 'gemini-1.5-pro-preview-0409',
      projectId: json['projectId'] ?? '',
      region: json['region'] ?? 'us-central1',
      accessToken: json['accessToken'] ?? '',
    );
  }

  @override
  List<ConfigField> get formFields => [
    ConfigField(key: 'modelName', label: 'Model Name', value: modelName),
    ConfigField(key: 'projectId', label: 'Project ID', value: projectId),
    ConfigField(key: 'region', label: 'Region', value: region),
    ConfigField(key: 'accessToken', label: 'Access Token', value: accessToken, isSecret: true),
  ];

  @override
  AIProviderConfig copyWithField(String key, String value) {
    return VertexAIConfig(
      modelName: key == 'modelName' ? value : modelName,
      projectId: key == 'projectId' ? value : projectId,
      region: key == 'region' ? value : region,
      accessToken: key == 'accessToken' ? value : accessToken,
    );
  }
}
