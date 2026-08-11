import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_data.dart';

class ProductRecord {
  final String id;
  final DateTime timestamp;
  final String productName;
  final String originalName;
  final String brand;
  final String origin;
  final String summary;
  final List<String> ingredients;
  final List<String> allergenAlerts;
  final List<String> dietaryFlags;
  final List<String> whenRecommended;
  final List<String> whenNotRecommended;
  final String? imagePath;

  ProductRecord({
    required this.id,
    required this.timestamp,
    required this.productName,
    required this.originalName,
    required this.brand,
    required this.origin,
    required this.summary,
    required this.ingredients,
    required this.allergenAlerts,
    required this.dietaryFlags,
    required this.whenRecommended,
    required this.whenNotRecommended,
    this.imagePath,
  });

  factory ProductRecord.fromAnalysisData(ProductAnalysisData data, {String? imagePath}) {
    return ProductRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      productName: data.productName.isNotEmpty ? data.productName : (data.originalName.isNotEmpty ? data.originalName : '未知商品'),
      originalName: data.originalName,
      brand: data.brand,
      origin: data.origin,
      summary: data.summary,
      ingredients: data.ingredients,
      allergenAlerts: data.allergens,
      dietaryFlags: data.dietaryFlags,
      whenRecommended: data.recommendedFor,
      whenNotRecommended: data.notRecommendedFor,
      imagePath: imagePath,
    );
  }

  // --- JSON-Backed Core Logic ---

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'originalName': originalName,
      'brand': brand,
      'origin': origin,
      'summary': summary,
      'ingredients': ingredients,
      'allergenAlerts': allergenAlerts,
      'dietaryFlags': dietaryFlags,
      'whenRecommended': whenRecommended,
      'whenNotRecommended': whenNotRecommended,
    };
  }

  String get rawJsonData => jsonEncode(toMap());

  factory ProductRecord.fromJsonBacked(String id, DateTime timestamp, String jsonString, String? imagePath) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProductRecord(
        id: id,
        timestamp: timestamp,
        productName: map['productName']?.toString() ?? '',
        originalName: map['originalName']?.toString() ?? '',
        brand: map['brand']?.toString() ?? '',
        origin: map['origin']?.toString() ?? '',
        summary: map['summary']?.toString() ?? '',
        ingredients: (map['ingredients'] as List?)?.map((e) => e.toString()).toList() ?? [],
        allergenAlerts: (map['allergenAlerts'] as List?)?.map((e) => e.toString()).toList() ?? [],
        dietaryFlags: (map['dietaryFlags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        whenRecommended: (map['whenRecommended'] as List?)?.map((e) => e.toString()).toList() ?? [],
        whenNotRecommended: (map['whenNotRecommended'] as List?)?.map((e) => e.toString()).toList() ?? [],
        imagePath: imagePath,
      );
    } catch (e) {
      // Fallback in case of parsing error
      return ProductRecord(
        id: id,
        timestamp: timestamp,
        productName: 'Error Loading Data',
        originalName: '',
        brand: '',
        origin: '',
        summary: '',
        ingredients: [],
        allergenAlerts: [],
        dietaryFlags: [],
        whenRecommended: [],
        whenNotRecommended: [],
        imagePath: imagePath,
      );
    }
  }
}

class ProductRecordAdapter extends TypeAdapter<ProductRecord> {
  // Completely Re-architected: JSON-Backed Persistence
  @override
  final int typeId = 10; // Breaking change from 2 to isolate corrupted data

  @override
  ProductRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final rawJsonData = reader.readString();
    final imagePath = reader.readString();

    return ProductRecord.fromJsonBacked(
      id,
      timestamp,
      rawJsonData,
      imagePath.isEmpty ? null : imagePath,
    );
  }

  @override
  void write(BinaryWriter writer, ProductRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.rawJsonData);
    writer.writeString(obj.imagePath ?? '');
  }
}
