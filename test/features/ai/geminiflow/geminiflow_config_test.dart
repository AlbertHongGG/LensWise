import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/features/ai/domain/models/ai_provider_config.dart';
import 'package:lens_wise/features/ai/infrastructure/providers/geminiflow/sdk/types.dart';

void main() {
  group('GeminiFlowConfig Tests', () {
    test('default configuration conforms to latest GeminiFlow specifications', () {
      const config = GeminiFlowConfig();

      expect(config.baseUrl, 'http://127.0.0.1:5000');
      expect(config.modelName, 'gemini-3.8-flash');
      expect(config.thinking, GeminiThinkingLevel.low);
    });

    test('toJson and fromJson correctly serialize and deserialize thinking and port', () {
      const config = GeminiFlowConfig(
        modelName: 'gemini-3-pro',
        baseUrl: 'http://192.168.1.100:5000',
        thinking: GeminiThinkingLevel.high,
      );

      final json = config.toJson();
      expect(json['modelName'], 'gemini-3-pro');
      expect(json['baseUrl'], 'http://192.168.1.100:5000');
      expect(json['thinking'], 'high');

      final deserialized = GeminiFlowConfig.fromJson(json);
      expect(deserialized.modelName, 'gemini-3-pro');
      expect(deserialized.baseUrl, 'http://192.168.1.100:5000');
      expect(deserialized.thinking, GeminiThinkingLevel.high);
    });

    test('copyWithField correctly updates thinking, modelName, and baseUrl', () {
      const config = GeminiFlowConfig();

      final updatedModel = config.copyWithField('modelName', 'gemini-3-pro') as GeminiFlowConfig;
      expect(updatedModel.modelName, 'gemini-3-pro');

      final updatedThinking = config.copyWithField('thinking', 'medium') as GeminiFlowConfig;
      expect(updatedThinking.thinking, GeminiThinkingLevel.medium);

      final updatedUrl = config.copyWithField('baseUrl', 'http://10.0.2.2:5000') as GeminiFlowConfig;
      expect(updatedUrl.baseUrl, 'http://10.0.2.2:5000');
    });

    test('fallbackTo cascades global config when agent config is empty', () {
      const globalConfig = GeminiFlowConfig(
        modelName: 'gemini-3-pro',
        baseUrl: 'http://192.168.1.50:5000',
        thinking: GeminiThinkingLevel.high,
      );

      const emptyAgentConfig = GeminiFlowConfig.empty();
      final effective = emptyAgentConfig.fallbackTo(globalConfig) as GeminiFlowConfig;

      expect(effective.modelName, 'gemini-3-pro');
      expect(effective.baseUrl, 'http://192.168.1.50:5000');
      expect(effective.thinking, GeminiThinkingLevel.high);
    });
  });
}
