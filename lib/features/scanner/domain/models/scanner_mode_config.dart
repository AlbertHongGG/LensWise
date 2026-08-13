enum ScannerMode { receipt, product, comparison }

class ScannerModeConfig {
  final ScannerMode mode;
  final String title;
  final int minShotsRequired;
  final int? maxShotsAllowed;
  final bool isAutoProcess;

  const ScannerModeConfig({
    required this.mode,
    required this.title,
    required this.minShotsRequired,
    required this.maxShotsAllowed,
    required this.isAutoProcess,
  });

  static const configurations = {
    ScannerMode.receipt: ScannerModeConfig(
      mode: ScannerMode.receipt,
      title: '收據',
      minShotsRequired: 1,
      maxShotsAllowed: 50,
      isAutoProcess: false,
    ),
    ScannerMode.product: ScannerModeConfig(
      mode: ScannerMode.product,
      title: '商品',
      minShotsRequired: 1,
      maxShotsAllowed: 50,
      isAutoProcess: false,
    ),
    ScannerMode.comparison: ScannerModeConfig(
      mode: ScannerMode.comparison,
      title: '比對',
      minShotsRequired: 2,
      maxShotsAllowed: null, // infinite
      isAutoProcess: false,
    ),
  };
}
