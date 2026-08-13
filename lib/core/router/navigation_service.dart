import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/router/app_router.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  void navigateToProductComparisonResult(ProductComparisonResult result, List<Uint8List> images) {
    final args = ProductComparisonResultArgs(result: result, rawImages: images);
    _router.pushReplacement('/result/comparison', extra: args);
  }

  void navigateToReceiptResult(ReceiptScannerRecord record, List<Uint8List> images) {
    // Navigate to receipt result page with record and raw images
    _router.pushReplacement('/result/receipt', extra: {
      'record': record,
      'memoryImages': images,
    });
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref.watch(routerProvider));
});
