import 'package:hive/hive.dart';

class ReceiptRecord {
  final String id;
  final DateTime timestamp;
  final String? storeName;
  final String? totalAmount;
  final List<Map<String, dynamic>> items;

  ReceiptRecord({
    required this.id,
    required this.timestamp,
    this.storeName,
    this.totalAmount,
    required this.items,
  });
}

class ReceiptRecordAdapter extends TypeAdapter<ReceiptRecord> {
  @override
  final int typeId = 1;

  @override
  ReceiptRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final storeName = reader.readString();
    final totalAmount = reader.readString();
    
    final itemsLength = reader.readInt();
    final items = <Map<String, dynamic>>[];
    for (var i = 0; i < itemsLength; i++) {
      final mapLength = reader.readInt();
      final map = <String, dynamic>{};
      for (var j = 0; j < mapLength; j++) {
        final key = reader.readString();
        final value = reader.read();
        map[key] = value;
      }
      items.add(map);
    }

    return ReceiptRecord(
      id: id,
      timestamp: timestamp,
      storeName: storeName.isEmpty ? null : storeName,
      totalAmount: totalAmount.isEmpty ? null : totalAmount,
      items: items,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.storeName ?? '');
    writer.writeString(obj.totalAmount ?? '');
    
    writer.writeInt(obj.items.length);
    for (final map in obj.items) {
      writer.writeInt(map.length);
      map.forEach((key, value) {
        writer.writeString(key);
        writer.write(value);
      });
    }
  }
}
