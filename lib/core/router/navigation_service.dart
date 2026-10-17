import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/router/app_router.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  void navigateToProductLensRecord(ProductLensRecord record, List<AppImageEntity> images) {
    _router.pushReplacement('/result', extra: record);
  }

  void navigateToProductComparisonRecord(ProductComparisonRecord record, List<AppImageEntity> images) {
    _router.pushReplacement('/result/comparison', extra: {
      'record': record,
      'memoryImages': images,
    });
  }

  void navigateToReceiptResult(ReceiptScannerRecord record, List<AppImageEntity> images) {
    // Navigate to receipt result page with record and raw images
    _router.pushReplacement('/result/receipt', extra: {
      'record': record,
      'memoryImages': images,
    });
  }

  void navigateToMenuRecord(MenuScannerRecord record, List<AppImageEntity> images) {
    _router.pushReplacement('/result/menu', extra: {
      'record': record,
      'memoryImages': images,
    });
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref.watch(routerProvider));
});
