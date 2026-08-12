enum ChatMessageType { user, ai, system, error }

class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String text;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
  });

  ChatMessage copyWith({
    String? id,
    ChatMessageType? type,
    String? text,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
