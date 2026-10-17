import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lens_wise/core/models/app_image_entity.dart';
import 'package:lens_wise/core/notifications/presentation/controllers/notification_controller.dart';
import 'package:lens_wise/core/notifications/models/app_notification.dart';
import 'package:lens_wise/core/utils/app_paths.dart';
import 'package:lens_wise/features/product_comparison/domain/models/product_comparison_record.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_page.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_hero_section.dart';
import 'package:lens_wise/features/product_comparison/presentation/widgets/immersive_comparison/comparison_roster_bar.dart';

class FakeNotificationController extends NotificationController {
  @override
  List<AppNotification> build() => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyImage1 = AppImageEntity(
    bytes: Uint8List.fromList([1, 2, 3]),
    source: ImageSourceType.camera,
  );
  final dummyImage2 = AppImageEntity(
    bytes: Uint8List.fromList([4, 5, 6]),
    source: ImageSourceType.camera,
  );

  setUp(() {
    AppPaths.setTestMediaDir('/test/media');
  });

  group('ComparisonResultPage Image Resolution', () {
    testWidgets('Live session prioritizes memoryImages over empty imagePaths without crashing', (tester) async {
      final recordWithEmptyPaths = ProductComparisonRecord.empty().copyWith(
        id: 'test_comp_1',
        title: '相機 vs 手機',
        summary: '比對總結說明',
        products: [
          const ComparisonProduct(originalName: 'Sony A7', translatedName: '索尼相機'),
          const ComparisonProduct(originalName: 'iPhone 15', translatedName: '蘋果手機'),
        ],
        imagePaths: const [], // Empty during streaming before disk persistence
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationProvider.overrideWith(() => FakeNotificationController()),
          ],
          child: MaterialApp(
            home: ComparisonResultPage(
              record: recordWithEmptyPaths,
              memoryImages: [dummyImage1, dummyImage2],
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify ComparisonHeroSection is mounted
      expect(find.byType(ComparisonHeroSection), findsOneWidget);

      // Verify product names are rendered in the hero section
      expect(find.text('索尼相機'), findsOneWidget);
      expect(find.text('蘋果手機'), findsOneWidget);
    });

    testWidgets('History mode resolves disk images using record.imagePaths safely', (tester) async {
      final historyRecord = ProductComparisonRecord.empty().copyWith(
        id: 'test_comp_2',
        title: '筆電比對',
        summary: '比對總結',
        products: [
          const ComparisonProduct(originalName: 'MacBook', translatedName: '蘋果筆電'),
          const ComparisonProduct(originalName: 'ThinkPad', translatedName: '聯想筆電'),
          const ComparisonProduct(originalName: 'Dell XPS', translatedName: '戴爾筆電'),
        ],
        imagePaths: const ['laptop1.jpg', 'laptop2.jpg', 'laptop3.jpg'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationProvider.overrideWith(() => FakeNotificationController()),
          ],
          child: MaterialApp(
            home: ComparisonResultPage(
              record: historyRecord,
              memoryImages: null, // History mode
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ComparisonHeroSection), findsOneWidget);
      expect(find.byType(ComparisonRosterBar), findsOneWidget);
      expect(find.text('蘋果筆電'), findsOneWidget);
      expect(find.text('聯想筆電'), findsOneWidget);
    });

    testWidgets('Edge case: empty record with 0 images renders fallback without exception', (tester) async {
      final emptyRecord = ProductComparisonRecord.empty();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationProvider.overrideWith(() => FakeNotificationController()),
          ],
          child: MaterialApp(
            home: ComparisonResultPage(
              record: emptyRecord,
              memoryImages: null,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ComparisonHeroSection), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
