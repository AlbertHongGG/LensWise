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
}

class ProductRecordAdapter extends TypeAdapter<ProductRecord> {
  @override
  final int typeId = 2;

  @override
  ProductRecord read(BinaryReader reader) {
    return ProductRecord(
      id: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      productName: reader.readString(),
      originalName: reader.readString(),
      brand: reader.readString(),
      origin: reader.readString(),
      summary: reader.readString(),
      ingredients: reader.readStringList(),
      allergenAlerts: reader.readStringList(),
      dietaryFlags: reader.readStringList(),
      whenRecommended: reader.readStringList(),
      whenNotRecommended: reader.readStringList(),
      imagePath: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeString(obj.productName);
    writer.writeString(obj.originalName);
    writer.writeString(obj.brand);
    writer.writeString(obj.origin);
    writer.writeString(obj.summary);
    writer.writeStringList(obj.ingredients);
    writer.writeStringList(obj.allergenAlerts);
    writer.writeStringList(obj.dietaryFlags);
    writer.writeStringList(obj.whenRecommended);
    writer.writeStringList(obj.whenNotRecommended);
    writer.writeString(obj.imagePath ?? '');
  }
}
