import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/voice/domain/interfaces/i_voice_recognition_service.dart';
import 'package:lens_wise/core/voice/domain/models/voice_state.dart';
import 'package:lens_wise/core/voice/domain/utils/voice_buffer_accumulator.dart';
import 'package:lens_wise/core/voice/infrastructure/services/stt_voice_recognition_service.dart';

class VoiceController extends Notifier<VoiceState> {
  late IVoiceRecognitionService _voiceService;
  VoiceBufferAccumulator _accumulator = VoiceBufferAccumulator();
  
  @override
  VoiceState build() {
    _voiceService = ref.watch(voiceRecognitionServiceProvider);
    return const VoiceState();
  }
  
  Future<void> initialize() async {
    await _voiceService.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          state = state.copyWith(isListening: false);
        } else if (status == 'error') {
          state = state.copyWith(isListening: false, hasError: true);
        }
      }
    );
  }
  
  Future<void> toggleListening() async {
    if (state.isListening) {
      await _voiceService.stopListening();
    } else {
      _accumulator = VoiceBufferAccumulator();
      state = const VoiceState(isListening: true, hasError: false, recognizedText: '');
      
      await _voiceService.startListening(
        onResult: (text, isFinal) {
          _accumulator.onNewText(text, isFinal);
          state = state.copyWith(recognizedText: _accumulator.fullText);
        }
      );
    }
  }
  
  Future<void> stopListening() async {
    if (state.isListening) {
      await _voiceService.stopListening();
    }
  }

  void clearText() {
    _accumulator = VoiceBufferAccumulator();
    state = state.copyWith(recognizedText: '');
  }
}

final voiceControllerProvider = NotifierProvider<VoiceController, VoiceState>(() {
  return VoiceController();
});
