String buildAiChatHistory(String text, bool isUser) {
  if (isUser) {
    return 'User: $text';
  } else {
    return 'AI: $text';
  }
}

String buildAiChatSystemPrompt() {
  return '你是一個專業的助理，請根據提供的內容與情境，簡潔、專業地回答問題。';
}
