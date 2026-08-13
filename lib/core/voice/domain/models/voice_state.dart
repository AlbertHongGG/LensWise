import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_state.freezed.dart';

@freezed
class VoiceState with _$VoiceState {
  const factory VoiceState({
    @Default(false) bool isListening,
    @Default(false) bool hasError,
    @Default('') String recognizedText,
  }) = _VoiceState;
}
