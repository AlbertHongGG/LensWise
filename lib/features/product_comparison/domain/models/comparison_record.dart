import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ComparisonRecord {
  final String id;
  final DateTime timestamp;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> differences;
  final String? valueAnalysis;
  final List<Map<String, dynamic>> decisionTree;
  final String? imagePath;

  ComparisonRecord({
    required this.id,
    required this.timestamp,
    required this.products,
    required this.differences,
    this.valueAnalysis,
    required this.decisionTree,
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
      products: parseList('products'),
      differences: data['differences'] is Map ? Map<String, dynamic>.from(data['differences'] as Map) : {},
      valueAnalysis: data['value_analysis']?.toString(),
      decisionTree: parseList('decision_tree'),
      imagePath: imagePath,
    );
  }
}

class ComparisonRecordAdapter extends TypeAdapter<ComparisonRecord> {
  @override
  final int typeId = 3;

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
    
    final prodLen = reader.readInt();
    final products = <Map<String, dynamic>>[];
    for (var i = 0; i < prodLen; i++) {
      products.add(_readMap(reader));
    }

    final differences = _readMap(reader);
    final valueAnalysis = reader.readString();
    
    final decLen = reader.readInt();
    final decisionTree = <Map<String, dynamic>>[];
    for (var i = 0; i < decLen; i++) {
      decisionTree.add(_readMap(reader));
    }

    return ComparisonRecord(
      id: id,
      timestamp: timestamp,
      products: products,
      differences: differences,
      valueAnalysis: valueAnalysis.isEmpty ? null : valueAnalysis,
      decisionTree: decisionTree,
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ComparisonRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    
    writer.writeInt(obj.products.length);
    for (final p in obj.products) {
      _writeMap(writer, p);
    }
    
    _writeMap(writer, obj.differences);
    writer.writeString(obj.valueAnalysis ?? '');
    
    writer.writeInt(obj.decisionTree.length);
    for (final d in obj.decisionTree) {
      _writeMap(writer, d);
    }
  }
}
