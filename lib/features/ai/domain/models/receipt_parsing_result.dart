class ReceiptParsingResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  ReceiptParsingResult({required this.status, this.message, this.data});

  factory ReceiptParsingResult.fromJson(Map<String, dynamic> json) {
    return ReceiptParsingResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
