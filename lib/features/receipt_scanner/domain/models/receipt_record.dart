import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ReceiptItem {
  final String originalName;
  final String translatedName;
  final double price;

  ReceiptItem({
    required this.originalName,
    required this.translatedName,
    required this.price,
  });

  ReceiptItem copyWith({
    String? originalName,
    String? translatedName,
    double? price,
  }) {
    return ReceiptItem(
      originalName: originalName ?? this.originalName,
      translatedName: translatedName ?? this.translatedName,
      price: price ?? this.price,
    );
  }

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      originalName: map['originalName']?.toString() ?? '',
      translatedName: map['translatedName']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ReceiptRecord {
  final String id;
  final DateTime timestamp;
  final String? storeName;
  final double totalAmount;
  final List<ReceiptItem> items;
  final String? imagePath;

  ReceiptRecord({
    required this.id,
    required this.timestamp,
    this.storeName,
    required this.totalAmount,
    required this.items,
    this.imagePath,
  });

  ReceiptRecord copyWith({
    String? storeName,
    double? totalAmount,
    List<ReceiptItem>? items,
  }) {
    return ReceiptRecord(
      id: this.id,
      timestamp: this.timestamp,
      storeName: storeName ?? this.storeName,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
      imagePath: this.imagePath,
    );
  }

  factory ReceiptRecord.fromAnalysisData(Map<String, dynamic> data, {String? imagePath}) {
    final List<ReceiptItem> processedItems = [];
    if (data['items'] is List) {
      for (final item in data['items'] as List) {
        if (item is Map<String, dynamic>) {
          processedItems.add(ReceiptItem.fromMap(item));
        } else if (item is Map) {
          processedItems.add(ReceiptItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ReceiptRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      storeName: data['storeName']?.toString() ?? '',
      totalAmount: double.tryParse(data['totalAmount']?.toString() ?? '0') ?? 0.0,
      items: processedItems,
      imagePath: imagePath,
    );
  }
}

class ReceiptRecordAdapter extends TypeAdapter<ReceiptRecord> {
  @override
  final int typeId = 1;

  @override
  ReceiptRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final storeName = reader.readString();
    final totalAmount = reader.readDouble();
    
    final itemsLength = reader.readInt();
    final items = <ReceiptItem>[];
    for (var i = 0; i < itemsLength; i++) {
      final originalName = reader.readString();
      final translatedName = reader.readString();
      final price = reader.readDouble();
      items.add(ReceiptItem(
        originalName: originalName,
        translatedName: translatedName,
        price: price,
      ));
    }

    return ReceiptRecord(
      id: id,
      timestamp: timestamp,
      storeName: storeName.isEmpty ? null : storeName,
      totalAmount: totalAmount,
      items: items,
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.storeName ?? '');
    writer.writeDouble(obj.totalAmount);
    
    writer.writeInt(obj.items.length);
    for (final item in obj.items) {
      writer.writeString(item.originalName);
      writer.writeString(item.translatedName);
      writer.writeDouble(item.price);
    }
    writer.writeString(obj.imagePath ?? '');
  }
}
