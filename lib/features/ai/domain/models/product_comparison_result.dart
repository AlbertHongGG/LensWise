class ProductComparisonResult {
  final String status;
  final String? message;
  final Map<String, dynamic>? data;

  ProductComparisonResult({required this.status, this.message, this.data});

  factory ProductComparisonResult.fromJson(Map<String, dynamic> json) {
    return ProductComparisonResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
