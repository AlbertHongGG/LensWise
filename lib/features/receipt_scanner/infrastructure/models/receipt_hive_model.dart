import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_record.dart';

@HiveType(typeId: 11)
class ReceiptHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  ReceiptHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory ReceiptHiveModel.fromDomain(ReceiptRecord record) {
    return ReceiptHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  ReceiptRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return ReceiptRecord.fromJson(map);
  }
}

class ReceiptHiveModelAdapter extends TypeAdapter<ReceiptHiveModel> {
  @override
  final int typeId = 11;

  @override
  ReceiptHiveModel read(BinaryReader reader) {
    return ReceiptHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
