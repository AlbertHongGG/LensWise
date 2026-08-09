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

class ComparisonResult {
  final String summary;
  final List<ComparisonPoint> comparisonPoints;

  ComparisonResult({
    required this.summary,
    required this.comparisonPoints,
  });

  factory ComparisonResult.fromJson(Map<String, dynamic> json) {
    return ComparisonResult(
      summary: json['summary'] as String? ?? '',
      comparisonPoints: (json['comparison_points'] as List<dynamic>?)
              ?.map((e) => ComparisonPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'comparison_points': comparisonPoints.map((e) => e.toJson()).toList(),
    };
  }
}
