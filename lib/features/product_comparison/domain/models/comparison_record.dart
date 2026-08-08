import 'package:hive/hive.dart';

class ComparisonRecord {
  final String id;
  final DateTime timestamp;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> differences;
  final String? valueAnalysis;
  final List<Map<String, dynamic>> decisionTree;

  ComparisonRecord({
    required this.id,
    required this.timestamp,
    required this.products,
    required this.differences,
    this.valueAnalysis,
    required this.decisionTree,
  });
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
