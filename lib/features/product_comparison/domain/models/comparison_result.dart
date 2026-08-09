class ComparisonPoint {
  final String aspect;
  final String leftValue;
  final String rightValue;

  ComparisonPoint({
    required this.aspect,
    required this.leftValue,
    required this.rightValue,
  });

  factory ComparisonPoint.fromJson(Map<String, dynamic> json) {
    return ComparisonPoint(
      aspect: json['aspect'] as String? ?? '',
      leftValue: json['left_value'] as String? ?? '',
      rightValue: json['right_value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'left_value': leftValue,
      'right_value': rightValue,
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
