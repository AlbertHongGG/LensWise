import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/widgets/streaming/streaming_skeleton.dart';
import 'package:lens_wise/features/menu_scanner/domain/models/menu_scanner_record.dart';
import 'package:lens_wise/features/menu_scanner/presentation/controllers/menu_scanner_controller.dart';
import 'package:lens_wise/features/menu_scanner/presentation/pages/menu_result_page.dart';
import 'package:lens_wise/features/menu_scanner/presentation/widgets/menu_list_item_tile.dart';

class FakeMenuScannerController extends MenuScannerController {
  final MenuScannerState _initial;

  FakeMenuScannerController(this._initial);

  @override
  MenuScannerState build() {
    return _initial;
  }

  void updateState(MenuScannerState newState) {
    state = newState;
  }
}

void main() {
  testWidgets('MenuListSection renders 3 skeletons when empty and streaming', (tester) async {
    final fakeController = FakeMenuScannerController(
      MenuScannerState(
        status: MenuScannerStatus.streaming,
        parsingResult: MenuScannerRecord.empty(),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          menuScannerControllerProvider.overrideWith(() => fakeController),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MenuListSection(
                initialRecord: MenuScannerRecord(
                  id: '1',
                  timestamp: DateTime(2026),
                  storeName: 'Test',
                  items: [],
                ),
                isDark: false,
                textColor: Colors.black,
                isLiveSession: true,
              ),
            ),
          ),
        ),
      ),
    );

    // Initial 3 skeletons when items is empty
    expect(find.byType(StreamingSkeleton), findsNWidgets(3));
    expect(find.byType(MenuListItemTile), findsNothing);
  });

  testWidgets('MenuListSection renders items progressively with streaming skeleton, then removes skeleton on finish', (tester) async {
    final fakeController = FakeMenuScannerController(
      MenuScannerState(
        status: MenuScannerStatus.streaming,
        parsingResult: MenuScannerRecord(
          id: '1',
          timestamp: DateTime.now(),
          storeName: 'Test Izakaya',
          items: const [
            MenuScannerItem(
              originalName: '焼き鳥',
              translatedName: '烤雞肉串',
              price: 180,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          menuScannerControllerProvider.overrideWith(() => fakeController),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MenuListSection(
                initialRecord: MenuScannerRecord(
                  id: '1',
                  timestamp: DateTime(2026),
                  storeName: 'Test',
                  items: [],
                ),
                isDark: false,
                textColor: Colors.black,
                isLiveSession: true,
              ),
            ),
          ),
        ),
      ),
    );

    // 1 item rendered and 1 skeleton below it indicating ongoing streaming
    expect(find.byType(MenuListItemTile), findsOneWidget);
    expect(find.text('烤雞肉串'), findsOneWidget);
    expect(find.text('焼き鳥'), findsOneWidget);
    expect(find.text('180'), findsOneWidget);
    expect(find.byType(StreamingSkeleton), findsOneWidget);

    // Now stream completes with 2 items
    fakeController.updateState(
      MenuScannerState(
        status: MenuScannerStatus.success,
        isStreamingComplete: true,
        parsingResult: MenuScannerRecord(
          id: '1',
          timestamp: DateTime.now(),
          storeName: 'Test Izakaya',
          items: const [
            MenuScannerItem(
              originalName: '焼き鳥',
              translatedName: '烤雞肉串',
              price: 180,
            ),
            MenuScannerItem(
              originalName: '生ビール',
              translatedName: '生啤酒',
              price: 550,
            ),
          ],
        ),
      ),
    );

    await tester.pump();

    // 2 items rendered, 0 skeletons
    expect(find.byType(MenuListItemTile), findsNWidgets(2));
    expect(find.text('烤雞肉串'), findsOneWidget);
    expect(find.text('生啤酒'), findsOneWidget);
    expect(find.byType(StreamingSkeleton), findsNothing);
  });
}
