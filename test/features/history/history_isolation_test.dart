import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/controllers/menu_scanner_controller.dart';
import 'package:lens_wise/features/menu_scanner/presentation/pages/menu_result_page.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_paper_card.dart';
import 'package:lens_wise/features/product_lens/domain/models/product_lens_record.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/hero_title_overlay.dart';
import 'package:lens_wise/features/product_lens/presentation/widgets/immersive_lens/verdict_floating_card.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_hero_section.dart';

// Fake Controllers holding leftover/active streaming state
class FakeMenuScannerController extends MenuScannerController {
  final MenuScannerState _initial;
  FakeMenuScannerController(this._initial);
  @override
  MenuScannerState build() => _initial;
}

class FakeReceiptScannerController extends ReceiptScannerController {
  final ReceiptScannerState _initial;
  FakeReceiptScannerController(this._initial);
  @override
  ReceiptScannerState build() => _initial;
}

class FakeProductLensController extends ProductLensController {
  final ProductLensState _initial;
  FakeProductLensController(this._initial);
  @override
  ProductLensState build() => _initial;
}

class FakeComparisonController extends ProductComparisonScannerController {
  final ProductComparisonScannerState _initial;
  FakeComparisonController(this._initial);
  @override
  ProductComparisonScannerState build() => _initial;
}

void main() {
  group('History Isolation & Controller Decoupling Tests', () {
    testWidgets('MenuListSection in History mode isolates from active controller state', (tester) async {
      final leftoverController = FakeMenuScannerController(
        MenuScannerState(
          status: MenuScannerStatus.streaming,
          parsingResult: MenuScannerRecord(
            id: 'controller-1',
            timestamp: DateTime.now(),
            storeName: 'Leftover Ramen',
            items: const [
              MenuScannerItem(
                originalName: '餃子',
                translatedName: '殘留煎餃',
                price: 100,
              ),
            ],
          ),
        ),
      );

      final historicalRecord = MenuScannerRecord(
        id: 'history-1',
        timestamp: DateTime(2025, 1, 1),
        storeName: '歷史居酒屋',
        items: const [
          MenuScannerItem(
            originalName: '刺身',
            translatedName: '歷史生魚片',
            price: 500,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            menuScannerControllerProvider.overrideWith(() => leftoverController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MenuListSection(
                  initialRecord: historicalRecord,
                  isDark: false,
                  textColor: Colors.black,
                  isLiveSession: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Must display history item, not leftover controller item
      expect(find.text('歷史生魚片'), findsOneWidget);
      expect(find.text('殘留煎餃'), findsNothing);
    });

    testWidgets('ReceiptPaperCard in History mode isolates from active controller state', (tester) async {
      final leftoverController = FakeReceiptScannerController(
        ReceiptScannerState(
          status: ReceiptScannerStatus.streaming,
          receiptRecord: ReceiptScannerRecord(
            id: 'controller-receipt',
            timestamp: DateTime.now(),
            storeName: '殘留全家超商',
            subtotal: 999.0,
            totalAmount: 999.0,
            items: const [
              ReceiptItem(originalName: 'Green Tea', translatedName: '殘留綠茶', price: 999.0),
            ],
          ),
        ),
      );

      final historicalRecord = ReceiptScannerRecord(
        id: 'history-receipt',
        timestamp: DateTime(2025, 1, 1),
        storeName: '歷史小七超商',
        subtotal: 50.0,
        totalAmount: 50.0,
        items: const [
          ReceiptItem(originalName: 'Black Tea', translatedName: '歷史紅茶', price: 50.0),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receiptScannerControllerProvider.overrideWith(() => leftoverController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ReceiptPaperCard(
                  initialRecord: historicalRecord,
                  onUpdate: (_) {},
                  isLiveSession: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Must display history store name and items, not controller leftover
      expect(find.text('歷史小七超商'), findsOneWidget);
      expect(find.text('歷史紅茶'), findsOneWidget);
      expect(find.text('殘留全家超商'), findsNothing);
      expect(find.text('殘留綠茶'), findsNothing);
    });

    testWidgets('Product Lens widgets in History mode isolate from active controller state', (tester) async {
      final leftoverController = FakeProductLensController(
        ProductLensState(
          status: ProductLensStatus.streaming,
          result: ProductLensRecord.empty().copyWith(
            productName: '殘留黑咖啡',
            summary: '這是殘留的咖啡總結',
          ),
        ),
      );

      final historicalRecord = ProductLensRecord.empty().copyWith(
        productName: '歷史綠茶',
        summary: '這是歷史的綠茶總結',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productLensControllerProvider.overrideWith(() => leftoverController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  HeroTitleOverlay(
                    initialRecord: historicalRecord,
                    isLiveSession: false,
                  ),
                  VerdictFloatingCard(
                    initialSummary: historicalRecord.summary,
                    isLiveSession: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Must display historical data, not leftover controller data
      expect(find.text('歷史綠茶'), findsOneWidget);
      expect(find.text('這是歷史的綠茶總結'), findsOneWidget);
      expect(find.text('殘留黑咖啡'), findsNothing);
      expect(find.text('這是殘留的咖啡總結'), findsNothing);
    });

    testWidgets('ComparisonHeroSection in History mode isolates from active controller state', (tester) async {
      final leftoverController = FakeComparisonController(
        ProductComparisonScannerState(
          status: ProductComparisonStatus.streaming,
          parsingResult: ProductComparisonRecord.empty().copyWith(
            products: const [
              ComparisonProduct(originalName: 'Leftover A', translatedName: '殘留商品A'),
              ComparisonProduct(originalName: 'Leftover B', translatedName: '殘留商品B'),
            ],
          ),
        ),
      );

      final historicalRecord = ProductComparisonRecord.empty().copyWith(
        products: const [
          ComparisonProduct(originalName: 'History A', translatedName: '歷史商品甲'),
          ComparisonProduct(originalName: 'History B', translatedName: '歷史商品乙'),
        ],
      );

      final kTransparentImage = Uint8List.fromList(<int>[
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productComparisonScannerControllerProvider.overrideWith(() => leftoverController),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ComparisonHeroSection(
                result: historicalRecord,
                leftIndex: 0,
                rightIndex: 1,
                imageProviderFactory: (_) => MemoryImage(kTransparentImage),
                isLiveSession: false,
              ),
            ),
          ),
        ),
      );

      // Must display history product names
      expect(find.text('歷史商品甲'), findsOneWidget);
      expect(find.text('歷史商品乙'), findsOneWidget);
      expect(find.text('殘留商品A'), findsNothing);
      expect(find.text('殘留商品B'), findsNothing);
    });
  });
}
