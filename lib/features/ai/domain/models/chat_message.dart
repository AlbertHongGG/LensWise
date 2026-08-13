import 'dart:typed_data';
import 'package:lens_wise/features/ai/domain/models/generate_response.dart';

enum ChatMessageType { user, ai, system, error }

class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String text;
  final DateTime timestamp;
  final List<AIImageResponse>? images;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
    this.images,
  });

  ChatMessage copyWith({
    String? id,
    ChatMessageType? type,
    String? text,
    DateTime? timestamp,
    List<AIImageResponse>? images,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      images: images ?? this.images,
    );
  }
}
