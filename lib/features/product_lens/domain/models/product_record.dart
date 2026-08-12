import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/product_analysis_agent/product_analysis_data.dart';
import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

class ProductRecord implements IHistoryRecord {
  @override
  final String id;
  @override
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
  final List<String> imagePaths;

  @override
  String get displayTitle => productName;

  @override
  String get displaySubtitle => brand.isEmpty ? '未知品牌' : brand;

  @override
  IconData get displayIcon => Icons.inventory_2_outlined;

  @override
  String? get deletionImagePath => null;

  @override
  List<String>? get deletionImagePaths => imagePaths;

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
    this.imagePaths = const [],
  });

  factory ProductRecord.fromAnalysisData(
    ProductAnalysisData data, {
    List<String> imagePaths = const [],
  }) {
    return ProductRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      productName: data.productName.isNotEmpty
          ? data.productName
          : (data.originalName.isNotEmpty ? data.originalName : '未知商品'),
      originalName: data.originalName,
      brand: data.brand,
      origin: data.origin,
      summary: data.summary,
      ingredients: data.ingredients,
      allergenAlerts: data.allergens,
      dietaryFlags: data.dietaryFlags,
      whenRecommended: data.recommendedFor,
      whenNotRecommended: data.notRecommendedFor,
      imagePaths: imagePaths,
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
      'imagePaths': imagePaths,
    };
  }

  String get rawJsonData => jsonEncode(toMap());

  factory ProductRecord.fromJsonBacked(
    String id,
    DateTime timestamp,
    String jsonString,
  ) {
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
        ingredients:
            (map['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
            [],
        allergenAlerts:
            (map['allergenAlerts'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        dietaryFlags:
            (map['dietaryFlags'] as List?)?.map((e) => e.toString()).toList() ??
            [],
        whenRecommended:
            (map['whenRecommended'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        whenNotRecommended:
            (map['whenNotRecommended'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        imagePaths:
            (map['imagePaths'] as List?)?.map((e) => e.toString()).toList() ??
            [],
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
        imagePaths: [],
      );
    }
  }
}

class ProductRecordAdapter extends TypeAdapter<ProductRecord> {
  // Completely Re-architected: JSON-Backed Persistence with Multi-Image Support
  @override
  final int typeId = 12; // Upgraded to v12 for multi-image architecture

  @override
  ProductRecord read(BinaryReader reader) {
    final id = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final rawJsonData = reader.readString();

    return ProductRecord.fromJsonBacked(id, timestamp, rawJsonData);
  }

  @override
  void write(BinaryWriter writer, ProductRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.rawJsonData);
  }
}
