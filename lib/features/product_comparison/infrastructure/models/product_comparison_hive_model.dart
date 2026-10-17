import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';

@HiveType(typeId: 13)
class ProductComparisonHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final String productsJson;

  @HiveField(5)
  final String comparisonPointsJson;

  @HiveField(6)
  final List<String> imagePaths;

  ProductComparisonHiveModel({
    required this.id,
    required this.timestampMs,
    required this.title,
    required this.summary,
    required this.productsJson,
    required this.comparisonPointsJson,
    required this.imagePaths,
  });

  factory ProductComparisonHiveModel.fromDomain(ProductComparisonRecord record) {
    return ProductComparisonHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      title: record.title,
      summary: record.summary,
      productsJson: jsonEncode(record.products.map((e) => e.toJson()).toList()),
      comparisonPointsJson: jsonEncode(record.comparisonPoints.map((e) => e.toJson()).toList()),
      imagePaths: record.imagePaths,
    );
  }

  ProductComparisonRecord toDomain() {
    return ProductComparisonRecord(
      id: id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      title: title,
      summary: summary,
      products: (jsonDecode(productsJson) as List<dynamic>)
          .map((e) => ComparisonProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      comparisonPoints: (jsonDecode(comparisonPointsJson) as List<dynamic>)
          .map((e) => ComparisonPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      imagePaths: imagePaths,
    );
  }
}

class ProductComparisonHiveModelAdapter extends TypeAdapter<ProductComparisonHiveModel> {
  @override
  final int typeId = 13;

  @override
  ProductComparisonHiveModel read(BinaryReader reader) {
    return ProductComparisonHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      title: reader.readString(),
      summary: reader.readString(),
      productsJson: reader.readString(),
      comparisonPointsJson: reader.readString(),
      imagePaths: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductComparisonHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.title);
    writer.writeString(obj.summary);
    writer.writeString(obj.productsJson);
    writer.writeString(obj.comparisonPointsJson);
    writer.writeStringList(obj.imagePaths);
  }
}
