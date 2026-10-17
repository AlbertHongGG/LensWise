import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

/// Robust, type-safe payload parser for Product Lens responses.
/// 
/// Handles dual-schema payloads (nested under `data` or flat in root),
/// safely normalizes string list fields (ingredients, allergens, flags),
/// and guarantees that partial streaming snapshots never throw TypeError.
class ProductLensPayloadParser {
  /// Resolves the actual data node from either a nested `{status, data: {...}}`
  /// response or a flat map.
  static Map<dynamic, dynamic> _resolveDataNode(Map<dynamic, dynamic> jsonMap) {
    final data = jsonMap['data'];
    if (data is Map) {
      return data;
    }
    return jsonMap;
  }

  /// Safely extracts and cleans a list of non-empty strings.
  static List<String> _parseStringList(dynamic rawList) {
    if (rawList is! List) return const [];
    final List<String> cleaned = [];
    for (final item in rawList) {
      if (item == null) continue;
      final str = item.toString().trim();
      if (str.isNotEmpty) {
        cleaned.add(str);
      }
    }
    return cleaned;
  }

  /// Parses an intermediate streaming snapshot for Product Lens.
  static ProductLensRecord parseStreamingSnapshot(Map<String, dynamic> jsonMap) {
    try {
      final dataNode = _resolveDataNode(jsonMap);

      final productName = dataNode['productName']?.toString().trim() ?? '';
      final originalName = dataNode['originalName']?.toString().trim() ?? '';
      final brand = dataNode['brand']?.toString().trim() ?? '';
      final origin = dataNode['origin']?.toString().trim() ?? '';
      final summary = dataNode['summary']?.toString().trim() ?? '';

      final ingredients = _parseStringList(dataNode['ingredients']);
      final allergenAlerts = _parseStringList(dataNode['allergens'] ?? dataNode['allergenAlerts']);
      final dietaryFlags = _parseStringList(dataNode['dietaryFlags']);
      final whenRecommended = _parseStringList(dataNode['recommendedFor'] ?? dataNode['whenRecommended']);
      final whenNotRecommended = _parseStringList(dataNode['notRecommendedFor'] ?? dataNode['whenNotRecommended']);

      return ProductLensRecord(
        id: '',
        timestamp: DateTime.now(),
        productName: productName,
        originalName: originalName,
        brand: brand,
        origin: origin,
        summary: summary,
        ingredients: ingredients,
        allergenAlerts: allergenAlerts,
        dietaryFlags: dietaryFlags,
        whenRecommended: whenRecommended,
        whenNotRecommended: whenNotRecommended,
        imagePaths: const [],
      );
    } catch (_) {
      return ProductLensRecord.empty();
    }
  }
}
