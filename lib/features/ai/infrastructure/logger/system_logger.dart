import 'dart:math';
import 'package:lens_wise/features/ai/infrastructure/logger/base_file_logger.dart';

class SystemLogger extends BaseFileLogger<Map<String, dynamic>> {
  SystemLogger() : super('system');

  @override
  String getFileName() {
    final parts = getTimestampParts();
    final yyyymmdd = parts['yyyymmdd'];
    final hhmmss = parts['hhmmss'];
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${yyyymmdd}_${hhmmss}_SystemLog_$random.json';
  }

  void logEvent(String eventType, dynamic data) {
    final logData = {
      'timestamp': getLocalISOString(DateTime.now()),
      'eventType': eventType,
      'data': data,
    };
    this.log(logData);
  }
}
