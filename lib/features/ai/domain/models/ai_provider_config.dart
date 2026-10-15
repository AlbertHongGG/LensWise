import 'package:flutter/material.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

enum AIProviderType { geminiflow, ollama, vertexai }

class FieldOption {
  final String value;
  final String label;
  final String? description;
  final IconData? icon;

  const FieldOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });
}

abstract class ConfigField {
  final String key;
  final String label;
  final String value;
  final String? hintValue;

  const ConfigField({
    required this.key,
    required this.label,
    required this.value,
    this.hintValue,
  });
}

class TextConfigField extends ConfigField {
  final bool isSecret;

  const TextConfigField({
    required super.key,
    required super.label,
    required super.value,
    super.hintValue,
    this.isSecret = false,
  });
}

class SelectConfigField extends ConfigField {
  final List<FieldOption> options;

  const SelectConfigField({
    required super.key,
    required super.label,
    required super.value,
    super.hintValue,
    required this.options,
  });

  String get displayLabel {
    final match = options.firstWhere(
      (opt) => opt.value.toLowerCase() == value.toLowerCase(),
      orElse: () => FieldOption(value: value, label: value),
    );
    return match.label;
  }
}

abstract class AIProviderConfig {
  final String modelName;

  const AIProviderConfig({required this.modelName});

  Map<String, dynamic> toJson();
  
  List<ConfigField> getFormFields([covariant AIProviderConfig? fallback]);
  
  AIProviderConfig copyWithField(String key, String value);

  AIProviderConfig fallbackTo(covariant AIProviderConfig fallback);
}

class GeminiFlowConfig extends AIProviderConfig {
  final String baseUrl;
  final GeminiThinkingLevel thinking;

  const GeminiFlowConfig({
    super.modelName = GeminiFlowModel.flash,
    this.baseUrl = 'http://127.0.0.1:5000',
    this.thinking = GeminiThinkingLevel.low,
  });

  const GeminiFlowConfig.empty()
      : baseUrl = '',
        thinking = GeminiThinkingLevel.low,
        super(modelName: '');

  @override
  Map<String, dynamic> toJson() => {
    'modelName': modelName,
    'baseUrl': baseUrl,
    'thinking': thinking.value,
  };

  factory GeminiFlowConfig.fromJson(Map<String, dynamic> json) {
    return GeminiFlowConfig(
      modelName: json['modelName'] ?? GeminiFlowModel.flash,
      baseUrl: json['baseUrl'] ?? 'http://127.0.0.1:5000',
      thinking: GeminiThinkingLevel.fromValue(json['thinking']),
    );
  }

  @override
  List<ConfigField> getFormFields([covariant GeminiFlowConfig? fallback]) => [
    SelectConfigField(
      key: 'modelName',
      label: '模型',
      value: modelName,
      hintValue: fallback?.modelName,
      options: GeminiFlowModel.modelItems.map((m) => FieldOption(
        value: m.id,
        label: m.displayName,
        description: m.description,
        icon: Icons.smart_toy_rounded,
      )).toList(),
    ),
    TextConfigField(
      key: 'baseUrl',
      label: 'Base URL',
      value: baseUrl,
      hintValue: fallback?.baseUrl,
    ),
    SelectConfigField(
      key: 'thinking',
      label: '思考強度',
      value: thinking.value,
      hintValue: fallback?.thinking.value,
      options: GeminiThinkingLevel.values.map((lvl) => FieldOption(
        value: lvl.value,
        label: lvl.label,
        description: lvl.description,
        icon: Icons.tune_rounded,
      )).toList(),
    ),
  ];

  @override
  AIProviderConfig copyWithField(String key, String value) {
    return GeminiFlowConfig(
      modelName: key == 'modelName' ? value : modelName,
      baseUrl: key == 'baseUrl' ? value : baseUrl,
      thinking: key == 'thinking' ? GeminiThinkingLevel.fromValue(value) : thinking,
    );
  }

  @override
  AIProviderConfig fallbackTo(covariant GeminiFlowConfig fallback) {
    final hasExplicitSettings = modelName.isNotEmpty || baseUrl.isNotEmpty;
    return GeminiFlowConfig(
      modelName: modelName.isNotEmpty ? modelName : fallback.modelName,
      baseUrl: baseUrl.isNotEmpty ? baseUrl : fallback.baseUrl,
      thinking: hasExplicitSettings ? thinking : fallback.thinking,
    );
  }
}

class OllamaConfig extends AIProviderConfig {
  final String baseUrl;

  const OllamaConfig({
    super.modelName = 'llama3',
    this.baseUrl = 'http://localhost:11434',
  });

  const OllamaConfig.empty() : baseUrl = '', super(modelName: '');

  @override
  Map<String, dynamic> toJson() => {'modelName': modelName, 'baseUrl': baseUrl};

  factory OllamaConfig.fromJson(Map<String, dynamic> json) {
    return OllamaConfig(
      modelName: json['modelName'] ?? 'llama3',
      baseUrl: json['baseUrl'] ?? 'http://localhost:11434',
    );
  }

  @override
  List<ConfigField> getFormFields([covariant OllamaConfig? fallback]) => [
    TextConfigField(key: 'modelName', label: 'Model Name', value: modelName, hintValue: fallback?.modelName),
    TextConfigField(key: 'baseUrl', label: 'Base URL', value: baseUrl, hintValue: fallback?.baseUrl),
  ];

  @override
  AIProviderConfig copyWithField(String key, String value) {
    return OllamaConfig(
      modelName: key == 'modelName' ? value : modelName,
      baseUrl: key == 'baseUrl' ? value : baseUrl,
    );
  }

  @override
  AIProviderConfig fallbackTo(covariant OllamaConfig fallback) {
    return OllamaConfig(
      modelName: modelName.isNotEmpty ? modelName : fallback.modelName,
      baseUrl: baseUrl.isNotEmpty ? baseUrl : fallback.baseUrl,
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

  const VertexAIConfig.empty() : projectId = '', region = '', accessToken = '', super(modelName: '');

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
  List<ConfigField> getFormFields([covariant VertexAIConfig? fallback]) => [
    TextConfigField(key: 'modelName', label: 'Model Name', value: modelName, hintValue: fallback?.modelName),
    TextConfigField(key: 'projectId', label: 'Project ID', value: projectId, hintValue: fallback?.projectId),
    TextConfigField(key: 'region', label: 'Region', value: region, hintValue: fallback?.region),
    TextConfigField(key: 'accessToken', label: 'Access Token', value: accessToken, hintValue: fallback?.accessToken, isSecret: true),
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

  @override
  AIProviderConfig fallbackTo(covariant VertexAIConfig fallback) {
    return VertexAIConfig(
      modelName: modelName.isNotEmpty ? modelName : fallback.modelName,
      projectId: projectId.isNotEmpty ? projectId : fallback.projectId,
      region: region.isNotEmpty ? region : fallback.region,
      accessToken: accessToken.isNotEmpty ? accessToken : fallback.accessToken,
    );
  }
}
