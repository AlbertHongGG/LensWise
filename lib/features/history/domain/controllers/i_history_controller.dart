import 'package:lens_wise/features/history/domain/models/i_history_record.dart';

abstract interface class IHistoryController {
  Future<void> saveRecord(IHistoryRecord record);
  Future<void> deleteRecord(IHistoryRecord record);
  Future<void> clearAll();
}
