class ProductComparisonResult {
  final String title;
  final String summary;
  final List<ComparisonProduct> products;
  final List<ComparisonPoint> comparisonPoints;

  ProductComparisonResult({
    required this.title,
    required this.summary,
    required this.products,
    required this.comparisonPoints,
  });

  factory ProductComparisonResult.fromJson(Map<String, dynamic> json) {
    return ProductComparisonResult(
      title: json['title'] as String? ?? '商品比對結果',
      summary: json['summary'] as String? ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => ComparisonProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comparisonPoints: (json['comparison_points'] as List<dynamic>?)
              ?.map((e) => ComparisonPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'products': products.map((e) => e.toJson()).toList(),
      'comparison_points': comparisonPoints.map((e) => e.toJson()).toList(),
    };
  }
}

class ComparisonProduct {
  final String originalName;
  final String translatedName;

  ComparisonProduct({
    required this.originalName,
    required this.translatedName,
  });

  factory ComparisonProduct.fromJson(Map<String, dynamic> json) {
    return ComparisonProduct(
      originalName: json['original_name'] as String? ?? '',
      translatedName: json['translated_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'translated_name': translatedName,
    };
  }
}

class ComparisonPoint {
  final String aspect;
  final List<String> values;

  ComparisonPoint({
    required this.aspect,
    required this.values,
  });

  factory ComparisonPoint.fromJson(Map<String, dynamic> json) {
    return ComparisonPoint(
      aspect: json['aspect'] as String? ?? '',
      values: (json['values'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'values': values,
    };
  }
}
