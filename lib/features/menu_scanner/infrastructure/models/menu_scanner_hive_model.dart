import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

@HiveType(typeId: 15)
class MenuScannerHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int timestampMs;

  @HiveField(2)
  final String rawJsonData;

  MenuScannerHiveModel({
    required this.id,
    required this.timestampMs,
    required this.rawJsonData,
  });

  factory MenuScannerHiveModel.fromDomain(MenuScannerRecord record) {
    return MenuScannerHiveModel(
      id: record.id,
      timestampMs: record.timestamp.millisecondsSinceEpoch,
      rawJsonData: jsonEncode(record.toJson()),
    );
  }

  MenuScannerRecord toDomain() {
    final map = jsonDecode(rawJsonData) as Map<String, dynamic>;
    return MenuScannerRecord.fromJson(map);
  }
}

class MenuScannerHiveModelAdapter extends TypeAdapter<MenuScannerHiveModel> {
  @override
  final int typeId = 15;

  @override
  MenuScannerHiveModel read(BinaryReader reader) {
    return MenuScannerHiveModel(
      id: reader.readString(),
      timestampMs: reader.readInt(),
      rawJsonData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, MenuScannerHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestampMs);
    writer.writeString(obj.rawJsonData);
  }
}
