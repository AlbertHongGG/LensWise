import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ComparisonRecord {
  final String id;
  final DateTime timestamp;
  final String summary;
  final List<Map<String, dynamic>> comparisonPoints;
  final String? imagePath;

  ComparisonRecord({
    required this.id,
    required this.timestamp,
    required this.summary,
    required this.comparisonPoints,
    this.imagePath,
  });

  factory ComparisonRecord.fromAnalysisData(Map<String, dynamic> data, {String? imagePath}) {
    List<Map<String, dynamic>> parseList(String key) {
      final list = <Map<String, dynamic>>[];
      if (data[key] is List) {
        for (final item in data[key] as List) {
          if (item is Map) {
            list.add(Map<String, dynamic>.from(item));
          }
        }
      }
      return list;
    }

    return ComparisonRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      summary: data['summary']?.toString() ?? '',
      comparisonPoints: parseList('comparison_points'),
      imagePath: imagePath,
    );
  }
}

class ComparisonRecordAdapter extends TypeAdapter<ComparisonRecord> {
  @override
  // Changed typeId to 4 to avoid conflict with old schema
  final int typeId = 4;

  Map<String, dynamic> _readMap(BinaryReader reader) {
    final length = reader.readInt();
    final map = <String, dynamic>{};
    for (var i = 0; i < length; i++) {
      final key = reader.readString();
      final value = reader.read();
      map[key] = value;
    }
    return map;
  }

  void _writeMap(BinaryWriter writer, Map<String, dynamic> map) {
    writer.writeInt(map.length);
    map.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }

  @override
  ComparisonRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final summary = reader.readString();
    
    final len = reader.readInt();
    final points = <Map<String, dynamic>>[];
    for (var i = 0; i < len; i++) {
      points.add(_readMap(reader));
    }

    return ComparisonRecord(
      id: id,
      timestamp: timestamp,
      summary: summary,
      comparisonPoints: points,
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ComparisonRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.summary);
    
    writer.writeInt(obj.comparisonPoints.length);
    for (final p in obj.comparisonPoints) {
      _writeMap(writer, p);
    }
    
    writer.writeString(obj.imagePath ?? '');
  }
}
