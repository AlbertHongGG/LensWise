import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/ai/domain/models/chat_message.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/ai_chat_agent/ai_chat_agent.dart';

class AiChatSessionState {
  final List<ChatMessage> messages;
  final bool isProcessing;
  final String? errorMessage;
  final String? systemContextPrompt;

  AiChatSessionState({
    this.messages = const [],
    this.isProcessing = false,
    this.errorMessage,
    this.systemContextPrompt,
  });

  AiChatSessionState copyWith({
    List<ChatMessage>? messages,
    bool? isProcessing,
    String? errorMessage,
    String? systemContextPrompt,
  }) {
    return AiChatSessionState(
      messages: messages ?? this.messages,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      systemContextPrompt: systemContextPrompt ?? this.systemContextPrompt,
    );
  }
}

class AiChatController extends Notifier<AiChatSessionState> {
  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  @override
  AiChatSessionState build() {
    return AiChatSessionState();
  }

  /// Initializes the generic chat with a specific context (e.g. from Product or Receipt)
  /// and an initial greeting message.
  void initialize({
    required String contextId,
    required String systemContextPrompt,
    required String initialMessage,
  }) {
    // Basic deduplication to avoid re-initializing if same context
    if (state.systemContextPrompt == systemContextPrompt &&
        state.messages.isNotEmpty)
      return;

    state = AiChatSessionState(
      systemContextPrompt: systemContextPrompt,
      messages: [
        ChatMessage(
          id: _generateId(),
          type: ChatMessageType.system,
          text: initialMessage,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty ||
        state.isProcessing ||
        state.systemContextPrompt == null)
      return;

    final userMessage = ChatMessage(
      id: _generateId(),
      type: ChatMessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );

    // Save history before adding the new query
    final history = List<ChatMessage>.from(state.messages);

    final aiMessageId = _generateId();
    var aiMessage = ChatMessage(
      id: aiMessageId,
      type: ChatMessageType.ai,
      text: '',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, aiMessage],
      isProcessing: true,
      errorMessage: null,
    );

    try {
      final agent = ref.read(aiChatAgentProvider);
      final request = AiChatRequest(
        systemContextPrompt: state.systemContextPrompt!,
        history: history,
        newQuery: text,
      );

      final stream = agent.executeStream(request);

      await for (final chunk in stream) {
        aiMessage = aiMessage.copyWith(text: aiMessage.text + chunk);

        final newMessages = List<ChatMessage>.from(state.messages);
        final index = newMessages.indexWhere((m) => m.id == aiMessageId);
        if (index != -1) {
          newMessages[index] = aiMessage;
          state = state.copyWith(messages: newMessages);
        }
      }

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      final newMessages = List<ChatMessage>.from(state.messages);
      final index = newMessages.indexWhere((m) => m.id == aiMessageId);
      
      final errorText = aiMessage.text.isEmpty 
          ? '發生錯誤：$e' 
          : '${aiMessage.text}\n\n[發生錯誤：$e]';
          
      if (index != -1) {
        newMessages[index] = aiMessage.copyWith(
          text: errorText,
          type: ChatMessageType.error,
        );
      } else {
        newMessages.add(ChatMessage(
          id: _generateId(),
          type: ChatMessageType.error,
          text: '發生錯誤：$e',
          timestamp: DateTime.now(),
        ));
      }
      
      state = state.copyWith(
        messages: newMessages,
        isProcessing: false,
      );
    }
  }

  void clear() {
    state = AiChatSessionState();
  }
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatSessionState>(
      () => AiChatController(),
    );
