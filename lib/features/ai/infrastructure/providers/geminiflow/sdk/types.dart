enum GeminiThinkingLevel {
  low('low', label: '低 (極速)'),
  medium('medium', label: '中 (平衡推理)'),
  high('high', label: '高 (極致思維鏈)');

  final String value;
  final String label;

  const GeminiThinkingLevel(this.value, {required this.label});

  static GeminiThinkingLevel fromValue(String? raw) {
    if (raw == null) return GeminiThinkingLevel.low;
    final lower = raw.trim().toLowerCase();
    return GeminiThinkingLevel.values.firstWhere(
      (e) => e.value == lower || e.name == lower,
      orElse: () => GeminiThinkingLevel.low,
    );
  }
}

class GeminiFlowModel {
  static const String flash = 'gemini-3.8-flash';
  static const String pro = 'gemini-3-pro';

  static const List<String> availableModels = [flash, pro];
}

class GeminiFlowChatRequest {
  final String prompt;
  final String model;
  final GeminiThinkingLevel thinking;
  final String? systemPrompt;
  final List<String>? images;
  final String? sessionId;
  final String language;
  final bool autoRefreshCookies;

  const GeminiFlowChatRequest({
    required this.prompt,
    this.model = GeminiFlowModel.flash,
    this.thinking = GeminiThinkingLevel.low,
    this.systemPrompt,
    this.images,
    this.sessionId,
    this.language = 'zh-TW',
    this.autoRefreshCookies = true,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'prompt': prompt,
      'model': model,
      'thinking': thinking.value,
      'language': language,
      'auto_refresh_cookies': autoRefreshCookies,
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
