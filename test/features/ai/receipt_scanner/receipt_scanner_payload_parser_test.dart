import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/ai/json_stream_pipeline.dart';
import 'package:lens_wise/features/ai/infrastructure/agents/receipt_scanner_agent/receipt_scanner_payload_parser.dart';
import 'package:lens_wise/features/receipt_scanner/domain/models/receipt_scanner_record.dart';

void main() {
  group('ReceiptItemDto Completeness Guard Tests', () {
    test('isComplete requires originalName, translatedName, and price', () {
      final complete = ReceiptItemDto.fromDynamic({
        'originalName': '有機鮮奶',
        'translatedName': 'Organic Milk',
        'price': 98.0,
      });
      expect(complete.isComplete, isTrue);
      expect(complete.originalName, '有機鮮奶');
      expect(complete.translatedName, 'Organic Milk');
      expect(complete.price, 98.0);

      final missingPrice = ReceiptItemDto.fromDynamic({
        'originalName': '有機鮮奶',
        'translatedName': 'Organic Milk',
      });
      expect(missingPrice.isComplete, isFalse);

      final emptyOriginal = ReceiptItemDto.fromDynamic({
        'originalName': '',
        'translatedName': 'Organic Milk',
        'price': 98.0,
      });
      expect(emptyOriginal.isComplete, isFalse);

      final emptyTranslated = ReceiptItemDto.fromDynamic({
        'originalName': '有機鮮奶',
        'translatedName': '',
        'price': 98.0,
      });
      expect(emptyTranslated.isComplete, isFalse);

      final nonMap = ReceiptItemDto.fromDynamic('random string');
      expect(nonMap.isComplete, isFalse);
    });

    test('ReceiptFeeItemDto completeness and negative amount handling', () {
      final discount = ReceiptFeeItemDto.fromDynamic({
        'name': '會員折扣',
        'amount': -20.0,
      });
      expect(discount.isComplete, isTrue);
      expect(discount.amount, -20.0);

      final stringDiscount = ReceiptFeeItemDto.fromDynamic({
        'name': '折價券',
        'amount': '-50',
      });
      expect(stringDiscount.isComplete, isTrue);
      expect(stringDiscount.amount, -50.0);

      final missingAmount = ReceiptFeeItemDto.fromDynamic({
        'name': '折扣',
      });
      expect(missingAmount.isComplete, isFalse);
    });
  });

  group('ReceiptScannerPayloadParser Tests', () {
    test('Parses nested data response with items and fees', () {
      final json = {
        'status': 'success',
        'data': {
          'storeName': '全聯福利中心',
          'receiptDateTime': '2026-10-17 14:30',
          'currency': 'TWD',
          'items': [
            {'originalName': '奇異果', 'translatedName': 'Kiwi', 'price': 45.0},
            {'originalName': '吐司', 'translatedName': 'Toast', 'price': 39.0},
          ],
          'discounts': [
            {'name': '點數折抵', 'amount': -10.0},
          ],
          'taxes': [
            {'name': '營業稅', 'amount': 4.0},
          ],
          'subtotal': 84.0,
          'totalAmount': 78.0,
        }
      };

      final record = ReceiptScannerPayloadParser.parseStreamingSnapshot(json);
      expect(record.storeName, '全聯福利中心');
      expect(record.receiptDate, '2026-10-17 14:30');
      expect(record.currency, 'TWD');
      expect(record.items.length, 2);
      expect(record.discounts.length, 1);
      expect(record.taxes.length, 1);
      expect(record.subtotal, 84.0);
      expect(record.totalAmount, 78.0);
    });

    test('Filters incomplete trailing item safely without throwing', () {
      final json = {
        'status': 'success',
        'data': {
          'storeName': 'FamilyMart',
          'items': [
            {'originalName': '咖啡', 'translatedName': 'Coffee', 'price': 55.0},
            // Incomplete trailing item: missing price
            {'originalName': '三明治', 'translatedName': 'Sandwich'},
          ],
        }
      };

      final record = ReceiptScannerPayloadParser.parseStreamingSnapshot(json);
      expect(record.items.length, 1);
      expect(record.items.first.originalName, '咖啡');
    });

    test('Simulate incremental streaming chunks through JsonStreamPipeline', () async {
      final fullJson = jsonEncode({
        'status': 'success',
        'data': {
          'storeName': '7-Eleven',
          'receiptDateTime': '2026-10-17',
          'currency': 'TWD',
          'items': [
            {'originalName': '御飯糰', 'translatedName': 'Rice Ball', 'price': 35.0},
            {'originalName': '茶葉蛋', 'translatedName': 'Tea Egg', 'price': 14.0},
            {'originalName': '熱拿鐵', 'translatedName': 'Hot Latte', 'price': 55.0},
          ],
          'totalAmount': 104.0,
        }
      });

      // Split into 15-char slices
      Stream<String> chunkStream() async* {
        for (int i = 0; i < fullJson.length; i += 15) {
          final end = (i + 15 < fullJson.length) ? i + 15 : fullJson.length;
          yield fullJson.substring(i, end);
          await Future.delayed(const Duration(milliseconds: 5));
        }
      }

      final pipeline = JsonStreamPipeline.bind<ReceiptScannerRecord>(
        rawStream: chunkStream(),
        mapper: ReceiptScannerPayloadParser.parseStreamingSnapshot,
        initialData: ReceiptScannerRecord.empty(),
        throttleDuration: const Duration(milliseconds: 20),
      );

      final snapshotCounts = <int>[];
      await for (final snapshot in pipeline) {
        snapshotCounts.add(snapshot.data.items.length);
      }

      expect(snapshotCounts.isNotEmpty, isTrue);
      expect(snapshotCounts.last, 3);
    });
  });
}
