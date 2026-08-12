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

    state = state.copyWith(
      messages: [...state.messages, userMessage],
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

      final responseText = await agent.execute(request);

      final aiMessage = ChatMessage(
        id: _generateId(),
        type: ChatMessageType.ai,
        text: responseText,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isProcessing: false,
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        id: _generateId(),
        type: ChatMessageType.error,
        text: '發生錯誤：$e',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
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
