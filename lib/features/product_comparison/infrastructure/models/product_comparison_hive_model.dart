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
  final String rawJsonResult;

  @HiveField(3)
  final String imagePath;

  ProductComparisonHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonResult,
    required this.imagePath,
  });

  factory ProductComparisonHiveModel.fromDomain(ProductComparisonRecord record) {
    return ProductComparisonHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonResult: record.rawJsonResult,
      imagePath: record.imagePath,
    );
  }

  ProductComparisonRecord toDomain() {
    return ProductComparisonRecord(
      id: id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      rawJsonResult: rawJsonResult,
      imagePath: imagePath,
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
      rawJsonResult: reader.readString(),
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductComparisonHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonResult);
    writer.writeString(obj.imagePath);
  }
}
