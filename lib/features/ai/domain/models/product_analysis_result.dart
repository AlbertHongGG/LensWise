import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_data.dart';

class ProductAnalysisResult {
  final String status;
  final String? message;
  final ProductAnalysisData? data;

  ProductAnalysisResult({required this.status, this.message, this.data});

  factory ProductAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisResult(
      status: json['status'] as String? ?? 'error',
      message: json['message'] as String?,
      data: json['data'] != null
          ? ProductAnalysisData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
