import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';

@HiveType(typeId: 14)
class ReceiptScannerHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  ReceiptScannerHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory ReceiptScannerHiveModel.fromDomain(ReceiptScannerRecord record) {
    return ReceiptScannerHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  ReceiptScannerRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return ReceiptScannerRecord.fromJson(map);
  }
}

class ReceiptScannerHiveModelAdapter extends TypeAdapter<ReceiptScannerHiveModel> {
  @override
  final int typeId = 14;

  @override
  ReceiptScannerHiveModel read(BinaryReader reader) {
    return ReceiptScannerHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptScannerHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
