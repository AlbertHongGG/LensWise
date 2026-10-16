import 'dart:typed_data';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';

abstract class IProductLensAgent {
  Future<ProductLensRecord> execute(List<Uint8List> input);
  Stream<StreamingSnapshot<ProductLensRecord>> executeStreamSnapshot(List<Uint8List> input);
}
