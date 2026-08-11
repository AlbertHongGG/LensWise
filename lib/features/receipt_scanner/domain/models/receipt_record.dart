import 'dart:convert';
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

  Map<String, dynamic> toMap() {
    return {
      'originalName': originalName,
      'translatedName': translatedName,
      'price': price,
    };
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
    };
  }

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
  final String? receiptDate;
  final String? storeName;
  final String? currency;
  final double subtotal;
  final List<ReceiptItem> items;
  final List<ReceiptFeeItem> discounts;
  final List<ReceiptFeeItem> taxes;
  final double totalAmount;
  final List<String> imagePaths;

  ReceiptRecord({
    required this.id,
    required this.timestamp,
    this.receiptDate,
    this.storeName,
    this.currency,
    required this.subtotal,
    required this.items,
    this.discounts = const [],
    this.taxes = const [],
    required this.totalAmount,
    this.imagePaths = const [],
  });

  ReceiptRecord copyWith({
    String? storeName,
    String? receiptDate,
    String? currency,
    double? subtotal,
    List<ReceiptItem>? items,
    List<ReceiptFeeItem>? discounts,
    List<ReceiptFeeItem>? taxes,
    double? totalAmount,
  }) {
    return ReceiptRecord(
      id: this.id,
      timestamp: this.timestamp,
      receiptDate: receiptDate ?? this.receiptDate,
      storeName: storeName ?? this.storeName,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      taxes: taxes ?? this.taxes,
      totalAmount: totalAmount ?? this.totalAmount,
      imagePaths: this.imagePaths,
    );
  }

  factory ReceiptRecord.fromAnalysisData(Map<String, dynamic> data, {List<String> imagePaths = const []}) {
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

    // Programmatically calculate subtotal to avoid LLM math errors
    final calculatedSubtotal = processedItems.fold<double>(0.0, (sum, item) => sum + item.price);

    // Programmatically calculate totalAmount (subtotal + sum(taxes) + sum(discounts))
    final sumTaxes = processedTaxes.fold<double>(0.0, (sum, item) => sum + item.amount);
    final sumDiscounts = processedDiscounts.fold<double>(0.0, (sum, item) => sum + item.amount);
    final calculatedTotal = calculatedSubtotal + sumTaxes + sumDiscounts;

    // Determine the receipt printed date/time
    String? parsedReceiptDate = data['receiptDateTime']?.toString();
    if (parsedReceiptDate != null && parsedReceiptDate.isEmpty) {
      parsedReceiptDate = null;
    }

    // Determine currency
    String? parsedCurrency = data['currency']?.toString();
    if (parsedCurrency != null && parsedCurrency.isEmpty) {
      parsedCurrency = null;
    }

    return ReceiptRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      receiptDate: parsedReceiptDate,
      storeName: data['storeName']?.toString() ?? '',
      currency: parsedCurrency,
      subtotal: calculatedSubtotal,
      items: processedItems,
      discounts: processedDiscounts,
      taxes: processedTaxes,
      totalAmount: calculatedTotal,
      imagePaths: imagePaths,
    );
  }

  // --- JSON-Backed Core Logic ---
  
  Map<String, dynamic> toMap() {
    return {
      'receiptDate': receiptDate,
      'storeName': storeName,
      'currency': currency,
      'subtotal': subtotal,
      'items': items.map((e) => e.toMap()).toList(),
      'discounts': discounts.map((e) => e.toMap()).toList(),
      'taxes': taxes.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'imagePaths': imagePaths,
    };
  }

  String get rawJsonData => jsonEncode(toMap());

  factory ReceiptRecord.fromJsonBacked(String id, DateTime timestamp, String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ReceiptRecord(
        id: id,
        timestamp: timestamp,
        receiptDate: map['receiptDate']?.toString(),
        storeName: map['storeName']?.toString(),
        currency: map['currency']?.toString(),
        subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
        items: (map['items'] as List?)?.map((e) => ReceiptItem.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
        discounts: (map['discounts'] as List?)?.map((e) => ReceiptFeeItem.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
        taxes: (map['taxes'] as List?)?.map((e) => ReceiptFeeItem.fromMap(Map<String, dynamic>.from(e))).toList() ?? [],
        totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
        imagePaths: (map['imagePaths'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    } catch (e) {
      // Fallback in case of parsing error
      return ReceiptRecord(
        id: id,
        timestamp: timestamp,
        subtotal: 0.0,
        items: [],
        totalAmount: 0.0,
        imagePaths: [],
      );
    }
  }
}

class ReceiptRecordAdapter extends TypeAdapter<ReceiptRecord> {
  // Completely Re-architected: JSON-Backed Persistence
  @override
  final int typeId = 11; // Upgraded to v6 to support imagePaths inside JSON

  @override
  ReceiptRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final rawJsonData = reader.readString();

    return ReceiptRecord.fromJsonBacked(
      id,
      timestamp,
      rawJsonData,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.rawJsonData);
  }
}
