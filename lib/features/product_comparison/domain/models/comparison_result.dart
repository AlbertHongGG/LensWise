class ComparisonPoint {
  final String aspect;
  final List<String> values;

  ComparisonPoint({
    required this.aspect,
    required this.values,
  });

  factory ComparisonPoint.fromJson(Map<String, dynamic> json) {
    List<String> parsedValues = [];
    
    // Support new array format
    if (json.containsKey('values') && json['values'] is List) {
      parsedValues = (json['values'] as List).map((e) => e.toString()).toList();
    } 
    // Fallback for legacy database records (Phase 42 schema)
    else {
      if (json.containsKey('left_value')) {
        parsedValues.add(json['left_value'].toString());
      }
      if (json.containsKey('right_value')) {
        parsedValues.add(json['right_value'].toString());
      }
    }

    return ComparisonPoint(
      aspect: json['aspect'] as String? ?? '',
      values: parsedValues,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'values': values,
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
      originalName: json['original_name'] as String? ?? '未知名稱',
      translatedName: json['translated_name'] as String? ?? 'Unknown Product',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'translated_name': translatedName,
    };
  }
}

class ComparisonResult {
  final String title;
  final String summary;
  final List<ComparisonProduct> products;
  final List<ComparisonPoint> comparisonPoints;

  ComparisonResult({
    required this.title,
    required this.summary,
    required this.products,
    required this.comparisonPoints,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) {
    return ComparisonResult(
      title: json['title'] as String? ?? '規格比對紀錄',
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
