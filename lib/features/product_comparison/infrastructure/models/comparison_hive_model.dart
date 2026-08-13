import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_record.dart';

@HiveType(typeId: 5)
class ComparisonHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  ComparisonHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory ComparisonHiveModel.fromDomain(ComparisonRecord record) {
    return ComparisonHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  ComparisonRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return ComparisonRecord.fromJson(map);
  }
}

class ComparisonHiveModelAdapter extends TypeAdapter<ComparisonHiveModel> {
  @override
  final int typeId = 5;

  @override
  ComparisonHiveModel read(BinaryReader reader) {
    return ComparisonHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ComparisonHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
