enum GeminiThinkingLevel {
  low('low', label: '低', description: '極速回應'),
  medium('medium', label: '中', description: '平衡推理'),
  high('high', label: '高', description: '極致思維鏈');

  final String value;
  final String label;
  final String description;

  const GeminiThinkingLevel(
    this.value, {
    required this.label,
    required this.description,
  });

  static GeminiThinkingLevel fromValue(String? raw) {
    if (raw == null) return GeminiThinkingLevel.low;
    final lower = raw.trim().toLowerCase();
    return GeminiThinkingLevel.values.firstWhere(
      (e) => e.value == lower || e.name == lower || e.label == raw.trim(),
      orElse: () => GeminiThinkingLevel.low,
    );
  }
}

class GeminiFlowModelItem {
  final String id;
  final String displayName;
  final String? description;

  const GeminiFlowModelItem({
    required this.id,
    required this.displayName,
    this.description,
  });
}

class GeminiFlowModel {
  static const String flash = 'gemini-3.8-flash';
  static const String pro = 'gemini-3-pro';
  static const String argon = 'gemini4Argon';

  static const List<GeminiFlowModelItem> modelItems = [
    GeminiFlowModelItem(
      id: flash,
      displayName: 'Gemini 3.8 Flash',
      description: '極速輕量',
    ),
    GeminiFlowModelItem(
      id: pro,
      displayName: 'Gemini 3 Pro',
      description: '旗艦推理',
    ),
    GeminiFlowModelItem(
      id: argon,
      displayName: 'Gemini 4 Argon',
      description: '次世代旗艦',
    ),
  ];

  static const List<String> availableModels = [flash, pro, argon];

  static String getDisplayName(String id) {
    final item = modelItems.firstWhere(
      (e) => e.id.toLowerCase() == id.trim().toLowerCase(),
      orElse: () => GeminiFlowModelItem(id: id, displayName: id),
    );
    return item.displayName;
  }
}

class GeminiFlowChatRequest {
  final String prompt;
  final String model;
  final GeminiThinkingLevel thinking;
  final String? systemPrompt;
  final List<String>? images;
  final String? sessionId;
  final String language;

  const GeminiFlowChatRequest({
    required this.prompt,
    this.model = GeminiFlowModel.flash,
    this.thinking = GeminiThinkingLevel.low,
    this.systemPrompt,
    this.images,
    this.sessionId,
    this.language = 'zh-TW',
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'prompt': prompt,
      'model': model,
      'thinking': thinking.value,
      'language': language,
    };
    if (systemPrompt != null && systemPrompt!.isNotEmpty) {
      map['system_prompt'] = systemPrompt;
    }
    if (sessionId != null && sessionId!.isNotEmpty) {
      map['session_id'] = sessionId;
    }
    if (images != null && images!.isNotEmpty) {
      map['images'] = images;
    }
    return map;
  }
}

class GeminiFlowChatResponse {
  final String text;
  final List<String> images;

  const GeminiFlowChatResponse({
    required this.text,
    this.images = const [],
  });

  factory GeminiFlowChatResponse.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final List<String> imagesList = [];
    if (imagesRaw is List) {
      imagesList.addAll(imagesRaw.map((e) => e.toString()));
    }
    return GeminiFlowChatResponse(
      text: json['text']?.toString() ?? '',
      images: imagesList,
    );
  }
}

class GeminiFlowStreamChunk {
  final String text;
  final List<String> images;

  const GeminiFlowStreamChunk({
    this.text = '',
    this.images = const [],
  });
}
