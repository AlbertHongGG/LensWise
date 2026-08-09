import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';

class ComparisonRecord {
  final String id;
  final DateTime timestamp;
  final String rawJsonResult;
  final String? imagePath;

  ComparisonRecord({
    required this.id,
    required this.timestamp,
    required this.rawJsonResult,
    this.imagePath,
  });

  factory ComparisonRecord.fromAnalysisData(Map<String, dynamic> data, {String? imagePath}) {
    return ComparisonRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      rawJsonResult: jsonEncode(data),
      imagePath: imagePath,
    );
  }

  ComparisonResult get result {
    final map = jsonDecode(rawJsonResult) as Map<String, dynamic>;
    return ComparisonResult.fromJson(map);
  }
}

class ComparisonRecordAdapter extends TypeAdapter<ComparisonRecord> {
  @override
  final int typeId = 5;

  @override
  ComparisonRecord read(BinaryReader reader) {
    return ComparisonRecord(
      id: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      rawJsonResult: reader.readString(),
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ComparisonRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.rawJsonResult);
    writer.writeString(obj.imagePath ?? '');
  }
}
