class ProductAnalysisData {
  final String productName;
  final String originalName;
  final String brand;
  final String origin;
  final String summary;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> dietaryFlags;
  final List<String> recommendedFor;
  final List<String> notRecommendedFor;

  ProductAnalysisData({
    required this.productName,
    required this.originalName,
    required this.brand,
    required this.origin,
    required this.summary,
    required this.ingredients,
    required this.allergens,
    required this.dietaryFlags,
    required this.recommendedFor,
    required this.notRecommendedFor,
  });

  factory ProductAnalysisData.fromJson(Map<String, dynamic> json) {
    return ProductAnalysisData(
      productName: json['productName'] as String? ?? '',
      originalName: json['originalName'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      allergens: (json['allergens'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dietaryFlags: (json['dietaryFlags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendedFor: (json['recommendedFor'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notRecommendedFor: (json['notRecommendedFor'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'originalName': originalName,
      'brand': brand,
      'origin': origin,
      'summary': summary,
      'ingredients': ingredients,
      'allergens': allergens,
      'dietaryFlags': dietaryFlags,
      'recommendedFor': recommendedFor,
      'notRecommendedFor': notRecommendedFor,
    };
  }
}
