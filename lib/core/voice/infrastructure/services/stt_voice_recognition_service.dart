import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lens_wise/core/voice/domain/interfaces/i_voice_recognition_service.dart';

class SttVoiceRecognitionService implements IVoiceRecognitionService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> initialize({
    required void Function(String status) onStatus,
  }) async {
    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: onStatus,
        onError: (error) {
          onStatus('error');
        },
      );
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startListening({
    required void Function(String recognizedWords, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) {
      final success = await initialize(onStatus: (_) {});
      if (!success) return;
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'zh_TW',
        pauseFor: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}

final voiceRecognitionServiceProvider = Provider<IVoiceRecognitionService>((ref) {
  return SttVoiceRecognitionService();
});
