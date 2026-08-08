import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/home/presentation/controllers/scanner_mode_strategy.dart';
import 'package:lens_wise/features/home/presentation/strategies/product_scanner_strategy.dart';
import 'package:lens_wise/features/home/presentation/strategies/receipt_scanner_strategy.dart';
import 'package:lens_wise/features/home/presentation/strategies/comparison_scanner_strategy.dart';

enum ScannerMode { receipt, product, comparison }

class ScannerModeController extends Notifier<ScannerMode> {
  late final Map<ScannerMode, ScannerModeStrategy> _strategies;

  @override
  ScannerMode build() {
    _strategies = {
      ScannerMode.receipt: ReceiptScannerStrategy(),
      ScannerMode.product: ProductScannerStrategy(),
      ScannerMode.comparison: ComparisonScannerStrategy(),
    };
    return ScannerMode.product; // Default mode
  }

  void setMode(ScannerMode mode) {
    state = mode;
  }

  ScannerModeStrategy get currentStrategy => _strategies[state]!;
}

final scannerModeProvider = NotifierProvider<ScannerModeController, ScannerMode>(() {
  return ScannerModeController();
});
