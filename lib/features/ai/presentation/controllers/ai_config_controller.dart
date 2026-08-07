import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_provider_config.dart';

class AIConfigController extends Notifier<AIProviderConfig> {
  @override
  AIProviderConfig build() {
    return const GeminiFlowConfig(
      baseUrl: 'http://127.0.0.1:8000',
      modelName: 'gemini-3.6-flash',
    );
  }
}

final aiConfigControllerProvider = NotifierProvider<AIConfigController, AIProviderConfig>(() {
  return AIConfigController();
});
