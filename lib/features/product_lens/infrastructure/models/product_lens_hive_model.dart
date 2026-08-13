import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

@HiveType(typeId: 12)
class ProductLensHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  ProductLensHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory ProductLensHiveModel.fromDomain(ProductLensRecord record) {
    return ProductLensHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  ProductLensRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return ProductLensRecord.fromJson(map);
  }
}

class ProductLensHiveModelAdapter extends TypeAdapter<ProductLensHiveModel> {
  @override
  final int typeId = 12;

  @override
  ProductLensHiveModel read(BinaryReader reader) {
    return ProductLensHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductLensHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
