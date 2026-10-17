import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/notifications/models/app_notification.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/features/ai/presentation/controllers/ai_config_controller.dart';
import 'package:lens_wise/features/menu_scanner/presentation/controllers/menu_scanner_controller.dart';
import 'package:lens_wise/features/menu_scanner/presentation/pages/menu_processing_page.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/controllers/receipt_scanner_controller.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_processing_page.dart';
import 'package:lens_wise/features/product_lens/presentation/controllers/product_lens_controller.dart';
import 'package:lens_wise/features/product_lens/presentation/pages/product_processing_page.dart';
import 'package:lens_wise/features/product_comparison/presentation/controllers/product_comparison_scanner_controller.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_processing_page.dart';

class FakeAIConfigController extends AIConfigController {
  final bool enabled;
  FakeAIConfigController({this.enabled = true});

  @override
  AIConfigState build() {
    return AIConfigState(
      globalProviderConfigs: const {},
      agentConfigs: const {},
      isAIAgentEnabled: enabled,
    );
  }
}

class FakeNotificationController extends NotificationController {
  @override
  List<AppNotification> build() => [];

  @override
  void showError(String message, {Duration duration = const Duration(seconds: 5)}) {}

  @override
  void showSuccess(String message, {Duration duration = const Duration(seconds: 4)}) {}
}

class SpyMenuScannerController extends MenuScannerController {
  int resetCount = 0;

  @override
  MenuScannerState build() => MenuScannerState();

  @override
  Future<void> analyzeMenu(List<AppImageEntity> images) async {
    state = state.copyWith(status: MenuScannerStatus.connecting);
  }

  @override
  void reset() {
    resetCount++;
    state = MenuScannerState();
  }
}

class SpyReceiptScannerController extends ReceiptScannerController {
  int resetCount = 0;

  @override
  ReceiptScannerState build() => ReceiptScannerState();

  @override
  Future<void> analyzeReceipt(List<AppImageEntity> images) async {
    state = state.copyWith(status: ReceiptScannerStatus.connecting);
  }

  @override
  void reset() {
    resetCount++;
    state = ReceiptScannerState();
  }
}

class SpyProductLensController extends ProductLensController {
  int resetCount = 0;

  @override
  ProductLensState build() => ProductLensState();

  @override
  Future<void> analyzeImage(List<AppImageEntity> images) async {
    state = state.copyWith(status: ProductLensStatus.connecting);
  }

  @override
  void reset() {
    resetCount++;
    state = ProductLensState();
  }
}

class SpyProductComparisonScannerController extends ProductComparisonScannerController {
  int resetCount = 0;

  @override
  ProductComparisonScannerState build() => ProductComparisonScannerState();

  @override
  Future<void> analyzeComparison(List<AppImageEntity> images) async {
    state = state.copyWith(status: ProductComparisonStatus.connecting);
  }

  @override
  void reset() {
    resetCount++;
    state = ProductComparisonScannerState();
  }
}

void main() {
  final dummyImage = AppImageEntity(
    bytes: Uint8List.fromList([1, 2, 3]),
    source: ImageSourceType.camera,
  );

  group('AI Switch (isAIAgentEnabled) Enforcement Tests', () {
    test('MenuScannerController rejects analysis when AI is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          aiConfigControllerProvider.overrideWith(() => FakeAIConfigController(enabled: false)),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      final controller = container.read(menuScannerControllerProvider.notifier);
      await controller.analyzeMenu([dummyImage]);

      final state = container.read(menuScannerControllerProvider);
      expect(state.status, MenuScannerStatus.error);
      expect(state.errorMessage, contains('AI 輔助未啟用'));
    });

    test('ReceiptScannerController rejects analysis when AI is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          aiConfigControllerProvider.overrideWith(() => FakeAIConfigController(enabled: false)),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      final controller = container.read(receiptScannerControllerProvider.notifier);
      await controller.analyzeReceipt([dummyImage]);

      final state = container.read(receiptScannerControllerProvider);
      expect(state.status, ReceiptScannerStatus.error);
      expect(state.errorMessage, contains('AI 輔助未啟用'));
    });

    test('ProductLensController rejects analysis when AI is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          aiConfigControllerProvider.overrideWith(() => FakeAIConfigController(enabled: false)),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      final controller = container.read(productLensControllerProvider.notifier);
      await controller.analyzeImage([dummyImage]);

      final state = container.read(productLensControllerProvider);
      expect(state.status, ProductLensStatus.error);
      expect(state.errorMessage, contains('AI 輔助未啟用'));
    });

    test('ProductComparisonScannerController rejects analysis when AI is disabled', () async {
      final container = ProviderContainer(
        overrides: [
          aiConfigControllerProvider.overrideWith(() => FakeAIConfigController(enabled: false)),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      final controller = container.read(productComparisonScannerControllerProvider.notifier);
      await controller.analyzeComparison([dummyImage]);

      final state = container.read(productComparisonScannerControllerProvider);
      expect(state.status, ProductComparisonStatus.error);
      expect(state.errorMessage, contains('AI 輔助未啟用'));
    });
  });

  group('ProcessingPage Early Cancel & Dispose Lifecycle Tests', () {
    testWidgets('MenuProcessingPage resets controller on pop before navigation', (tester) async {
      final spy = SpyMenuScannerController();
      final container = ProviderContainer(
        overrides: [
          menuScannerControllerProvider.overrideWith(() => spy),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MenuProcessingPage(memoryImages: [dummyImage])),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      // Tap to push
      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Pop before navigation
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(spy.resetCount, greaterThanOrEqualTo(2));
      expect(spy.state.status, MenuScannerStatus.idle);
    });

    testWidgets('ReceiptProcessingPage resets controller on pop before navigation', (tester) async {
      final spy = SpyReceiptScannerController();
      final container = ProviderContainer(
        overrides: [
          receiptScannerControllerProvider.overrideWith(() => spy),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReceiptProcessingPage(memoryImages: [dummyImage])),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(spy.resetCount, greaterThanOrEqualTo(2));
      expect(spy.state.status, ReceiptScannerStatus.idle);
    });

    testWidgets('ProductProcessingPage resets controller on pop before navigation', (tester) async {
      final spy = SpyProductLensController();
      final container = ProviderContainer(
        overrides: [
          productLensControllerProvider.overrideWith(() => spy),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductProcessingPage(memoryImages: [dummyImage])),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(spy.resetCount, greaterThanOrEqualTo(2));
      expect(spy.state.status, ProductLensStatus.idle);
    });

    testWidgets('ComparisonProcessingPage resets controller on pop before navigation', (tester) async {
      final spy = SpyProductComparisonScannerController();
      final container = ProviderContainer(
        overrides: [
          productComparisonScannerControllerProvider.overrideWith(() => spy),
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ComparisonProcessingPage(memoryImages: [dummyImage])),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(spy.resetCount, greaterThanOrEqualTo(2));
      expect(spy.state.status, ProductComparisonStatus.idle);
    });
  });
}
