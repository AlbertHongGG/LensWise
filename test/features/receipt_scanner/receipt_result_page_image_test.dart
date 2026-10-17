import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/notifications/models/app_notification.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/pages/receipt_result_page.dart';
import 'package:lens_wise/features/receipt_scanner/presentation/widgets/immersive_receipt/receipt_image_carousel.dart';

class FakeNotificationController extends NotificationController {
  @override
  List<AppNotification> build() => [];
}

void main() {
  final dummyImage = AppImageEntity(
    bytes: Uint8List.fromList([1, 2, 3]),
    source: ImageSourceType.camera,
  );

  testWidgets('ReceiptResultPage prioritizes memoryImages over empty imagePaths in live session', (tester) async {
    final recordWithEmptyPaths = ReceiptScannerRecord.empty().copyWith(
      id: 'test_rec_1',
      storeName: '7-Eleven',
      imagePaths: [], // Empty during streaming before disk persistence
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWith(() => FakeNotificationController()),
        ],
        child: MaterialApp(
          home: ReceiptResultPage(
            record: recordWithEmptyPaths,
            memoryImages: [dummyImage],
          ),
        ),
      ),
    );

    // Initial render
    await tester.pump();

    // Verify FAB for image is present
    final imageFab = find.byIcon(Icons.image_outlined);
    expect(imageFab, findsOneWidget);

    // Tap to open image drawer
    await tester.tap(imageFab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ReceiptImageCarousel is mounted
    expect(find.byType(ReceiptImageCarousel), findsOneWidget);

    // Verify that the empty placeholder (Icons.receipt_long) is NOT shown!
    expect(find.byIcon(Icons.receipt_long), findsNothing);

    // Verify PageView is present displaying the memory image
    expect(find.byType(PageView), findsOneWidget);
  });
}
