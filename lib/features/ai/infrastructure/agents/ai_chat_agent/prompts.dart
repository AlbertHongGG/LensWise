String buildAiChatHistory(String text, bool isUser) {
  if (isUser) {
    return 'User: $text';
  } else {
    return 'AI: $text';
  }
}
