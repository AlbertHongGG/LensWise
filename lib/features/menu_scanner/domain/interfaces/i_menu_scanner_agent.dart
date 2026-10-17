import 'dart:typed_data';
import 'package:lens_wise/core/ai/streaming_snapshot.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';

abstract class IMenuScannerAgent {
  Future<MenuScannerRecord> execute(List<Uint8List> input);
  Stream<StreamingSnapshot<MenuScannerRecord>> executeStreamSnapshot(List<Uint8List> input);
}
