import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_record.dart';

@HiveType(typeId: 12)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  ProductHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory ProductHiveModel.fromDomain(ProductRecord record) {
    return ProductHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  ProductRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return ProductRecord.fromJson(map);
  }
}

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 12;

  @override
  ProductHiveModel read(BinaryReader reader) {
    return ProductHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
