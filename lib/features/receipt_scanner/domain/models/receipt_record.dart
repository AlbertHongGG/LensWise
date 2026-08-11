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

class ReceiptFeeItem {
  final String name;
  final double amount;

  ReceiptFeeItem({
    required this.name,
    required this.amount,
  });

  factory ReceiptFeeItem.fromMap(Map<String, dynamic> map) {
    return ReceiptFeeItem(
      name: map['name']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ReceiptRecord {
  final String id;
  final DateTime timestamp;
  final String? storeName;
  final double subtotal;
  final List<ReceiptItem> items;
  final List<ReceiptFeeItem> discounts;
  final List<ReceiptFeeItem> taxes;
  final double totalAmount;
  final String? imagePath;

  ReceiptRecord({
    required this.id,
    required this.timestamp,
    this.storeName,
    required this.subtotal,
    required this.items,
    this.discounts = const [],
    this.taxes = const [],
    required this.totalAmount,
    this.imagePath,
  });

  ReceiptRecord copyWith({
    String? storeName,
    double? subtotal,
    List<ReceiptItem>? items,
    List<ReceiptFeeItem>? discounts,
    List<ReceiptFeeItem>? taxes,
    double? totalAmount,
  }) {
    return ReceiptRecord(
      id: this.id,
      timestamp: this.timestamp,
      storeName: storeName ?? this.storeName,
      subtotal: subtotal ?? this.subtotal,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      taxes: taxes ?? this.taxes,
      totalAmount: totalAmount ?? this.totalAmount,
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

    final List<ReceiptFeeItem> processedDiscounts = [];
    if (data['discounts'] is List) {
      for (final item in data['discounts'] as List) {
        if (item is Map<String, dynamic>) {
          processedDiscounts.add(ReceiptFeeItem.fromMap(item));
        } else if (item is Map) {
          processedDiscounts.add(ReceiptFeeItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    final List<ReceiptFeeItem> processedTaxes = [];
    if (data['taxes'] is List) {
      for (final item in data['taxes'] as List) {
        if (item is Map<String, dynamic>) {
          processedTaxes.add(ReceiptFeeItem.fromMap(item));
        } else if (item is Map) {
          processedTaxes.add(ReceiptFeeItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ReceiptRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      storeName: data['storeName']?.toString() ?? '',
      subtotal: double.tryParse(data['subtotal']?.toString() ?? '0') ?? 0.0,
      items: processedItems,
      discounts: processedDiscounts,
      taxes: processedTaxes,
      totalAmount: double.tryParse(data['totalAmount']?.toString() ?? '0') ?? 0.0,
      imagePath: imagePath,
    );
  }
}

class ReceiptRecordAdapter extends TypeAdapter<ReceiptRecord> {
  // Breaking Change! Increased typeId to 2 to isolate from old version.
  @override
  final int typeId = 2;

  @override
  ReceiptRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final storeName = reader.readString();
    final subtotal = reader.readDouble();
    final totalAmount = reader.readDouble();
    
    // Read items
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

    // Read discounts
    final discountsLength = reader.readInt();
    final discounts = <ReceiptFeeItem>[];
    for (var i = 0; i < discountsLength; i++) {
      final name = reader.readString();
      final amount = reader.readDouble();
      discounts.add(ReceiptFeeItem(name: name, amount: amount));
    }

    // Read taxes
    final taxesLength = reader.readInt();
    final taxes = <ReceiptFeeItem>[];
    for (var i = 0; i < taxesLength; i++) {
      final name = reader.readString();
      final amount = reader.readDouble();
      taxes.add(ReceiptFeeItem(name: name, amount: amount));
    }

    final imagePath = reader.readString();

    return ReceiptRecord(
      id: id,
      timestamp: timestamp,
      storeName: storeName.isEmpty ? null : storeName,
      subtotal: subtotal,
      totalAmount: totalAmount,
      items: items,
      discounts: discounts,
      taxes: taxes,
      imagePath: imagePath.isEmpty ? null : imagePath,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.storeName ?? '');
    writer.writeDouble(obj.subtotal);
    writer.writeDouble(obj.totalAmount);
    
    writer.writeInt(obj.items.length);
    for (final item in obj.items) {
      writer.writeString(item.originalName);
      writer.writeString(item.translatedName);
      writer.writeDouble(item.price);
    }

    writer.writeInt(obj.discounts.length);
    for (final discount in obj.discounts) {
      writer.writeString(discount.name);
      writer.writeDouble(discount.amount);
    }

    writer.writeInt(obj.taxes.length);
    for (final tax in obj.taxes) {
      writer.writeString(tax.name);
      writer.writeDouble(tax.amount);
    }

    writer.writeString(obj.imagePath ?? '');
  }
}
