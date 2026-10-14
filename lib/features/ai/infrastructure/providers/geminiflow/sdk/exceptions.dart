class GeminiFlowException implements Exception {
  final String message;
  final int? statusCode;

  const GeminiFlowException(this.message, [this.statusCode]);

  @override
  String toString() =>
      statusCode != null
          ? 'GeminiFlowException ($statusCode): $message'
          : 'GeminiFlowException: $message';
}

/// 401: Google 憑證過期或未完成登入授權
class GeminiFlowAuthException extends GeminiFlowException {
  const GeminiFlowAuthException([
    String message = 'Google 帳號未授權或憑證已過期，請於手機端 GeminiFlow App 重新登入',
  ]) : super(message, 401);
}

/// 400: 缺少必要參數（如 prompt 或 model）
class GeminiFlowBadRequestException extends GeminiFlowException {
  const GeminiFlowBadRequestException(String message) : super(message, 400);
}

/// 422: 傳入無效的 Base64 圖片資料或參數損毀
class GeminiFlowPayloadException extends GeminiFlowException {
  const GeminiFlowPayloadException(String message) : super(message, 422);
}

/// 500 / 502: 伺服器內部錯誤或 Google 連線失敗
class GeminiFlowServerException extends GeminiFlowException {
  const GeminiFlowServerException(super.message, [super.statusCode = 500]);
}
