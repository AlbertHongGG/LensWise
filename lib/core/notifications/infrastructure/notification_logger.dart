import 'dart:math';
import 'package:lens_wise/features/ai/infrastructure/logger/base_file_logger.dart';

class NotificationLogger extends BaseFileLogger<Map<String, dynamic>> {
  NotificationLogger() : super('notifications');

  @override
  String getFileName() {
    final parts = getTimestampParts();
    final yyyymmdd = parts['yyyymmdd'];
    final hhmmss = parts['hhmmss'];
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${yyyymmdd}_${hhmmss}_Notification_$random.json';
  }

  void logNotification(String type, String message) {
    final logData = {
      'timestamp': getLocalISOString(DateTime.now()),
      'type': type,
      'message': message,
    };
    this.log(logData);
  }
}
