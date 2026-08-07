class AIConnectionError implements Exception {
  final String providerName;
  final String message;

  AIConnectionError(this.providerName, this.message);

  @override
  String toString() {
    return 'AIConnectionError[$providerName]: $message';
  }
}
