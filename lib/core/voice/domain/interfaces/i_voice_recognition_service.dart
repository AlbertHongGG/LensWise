abstract class IVoiceRecognitionService {
  bool get isListening;
  bool get isInitialized;

  Future<bool> initialize({
    required void Function(String status) onStatus,
  });

  Future<void> startListening({
    required void Function(String recognizedWords, bool isFinal) onResult,
  });

  Future<void> stopListening();
}
