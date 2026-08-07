abstract class AILogger {
  void logRequest(String agentName, String prompt, {bool hasImage = false});
  void logResponse(String agentName, String response, Duration duration);
  void logError(String agentName, Object error, StackTrace stackTrace);
}
