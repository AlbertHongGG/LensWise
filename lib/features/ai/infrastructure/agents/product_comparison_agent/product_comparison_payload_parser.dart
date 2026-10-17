import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

/// Data transfer object for a single compared product candidate with completeness guard.
class ComparisonProductDto {
  final String originalName;
  final String translatedName;

  const ComparisonProductDto({
    required this.originalName,
    required this.translatedName,
  });

  bool get isComplete =>
      originalName.trim().isNotEmpty && translatedName.trim().isNotEmpty;

  factory ComparisonProductDto.fromDynamic(dynamic raw) {
    if (raw is! Map) {
      return const ComparisonProductDto(originalName: '', translatedName: '');
    }

    final originalName = raw['originalName']?.toString().trim() ?? '';
    final translatedName = raw['translatedName']?.toString().trim() ?? '';

    return ComparisonProductDto(
      originalName: originalName,
      translatedName: translatedName,
    );
  }

  ComparisonProduct toDomain() {
    return ComparisonProduct(
      originalName: originalName,
      translatedName: translatedName,
    );
  }
}

/// Data transfer object for a single comparison dimension with completeness guard.
class ComparisonPointDto {
  final String aspect;
  final List<String> values;

  const ComparisonPointDto({
    required this.aspect,
    required this.values,
  });

  /// 只有維度名稱非空、數值陣列非空且內部所有條目皆已完整閉合非空時，才視為完整，
  /// 防止左右多欄對比矩陣出現不對稱破版。
  bool get isComplete =>
      aspect.trim().isNotEmpty &&
      values.isNotEmpty &&
      values.every((v) => v.trim().isNotEmpty);

  factory ComparisonPointDto.fromDynamic(dynamic raw) {
    if (raw is! Map) {
      return const ComparisonPointDto(aspect: '', values: []);
    }

    final aspect = raw['aspect']?.toString().trim() ?? '';
    final rawValues = raw['values'];
    final List<String> values = [];

    if (rawValues is List) {
      for (final v in rawValues) {
        if (v != null) {
          values.add(v.toString().trim());
        }
      }
    }

    return ComparisonPointDto(aspect: aspect, values: values);
  }

  ComparisonPoint toDomain() {
    return ComparisonPoint(aspect: aspect, values: values);
  }
}

/// Robust, type-safe payload parser for Product Comparison responses.
/// 
/// Handles dual-schema payloads (nested under `data` or flat in root),
/// guarantees that multi-product comparison matrix dimensions never break during streaming,
/// and safeguards against type errors on partial snapshots.
class ProductComparisonPayloadParser {
  /// Resolves the actual data node from either a nested `{status, data: {...}}`
  /// response or a flat map.
  static Map<dynamic, dynamic> _resolveDataNode(Map<dynamic, dynamic> jsonMap) {
    final data = jsonMap['data'];
    if (data is Map) {
      return data;
    }
    return jsonMap;
  }

  /// Parses an intermediate streaming snapshot for Product Comparison.
  static ProductComparisonRecord parseStreamingSnapshot(Map<String, dynamic> jsonMap) {
    try {
      final dataNode = _resolveDataNode(jsonMap);

      final title = dataNode['title']?.toString().trim() ?? '';
      final summary = dataNode['summary']?.toString().trim() ?? '';

      // Products
      final rawProducts = dataNode['products'];
      final List<ComparisonProduct> completeProducts = [];
      if (rawProducts is List) {
        for (final raw in rawProducts) {
          final dto = ComparisonProductDto.fromDynamic(raw);
          if (dto.isComplete) {
            completeProducts.add(dto.toDomain());
          }
        }
      }

      // Comparison Points
      final rawPoints = dataNode['comparisonPoints'];
      final List<ComparisonPoint> completePoints = [];
      if (rawPoints is List) {
        for (final raw in rawPoints) {
          final dto = ComparisonPointDto.fromDynamic(raw);
          if (dto.isComplete) {
            completePoints.add(dto.toDomain());
          }
        }
      }

      return ProductComparisonRecord(
        id: '',
        timestamp: DateTime.now(),
        imagePath: '',
        title: title.isNotEmpty ? title : '商品比對結果',
        summary: summary,
        products: completeProducts,
        comparisonPoints: completePoints,
      );
    } catch (_) {
      return ProductComparisonRecord.empty();
    }
  }
}
