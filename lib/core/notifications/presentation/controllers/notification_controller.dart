import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_notification.dart';

class NotificationController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return [];
  }

  void _add(String message, NotificationType type, {Duration? duration}) {
    final notification = AppNotification(
      message: message,
      type: type,
      duration: duration ?? const Duration(seconds: 4),
    );
    
    // Max 3 notifications on screen, drop oldest if exceeded
    final newState = [...state, notification];
    if (newState.length > 3) {
      newState.removeAt(0);
    }
    state = newState;

    Timer(notification.duration, () {
      remove(notification.id);
    });
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void showSuccess(String message, {Duration? duration}) {
    _add(message, NotificationType.success, duration: duration);
  }

  void showError(String message, {Duration? duration}) {
    _add(message, NotificationType.error, duration: duration);
  }

  void showInfo(String message, {Duration? duration}) {
    _add(message, NotificationType.info, duration: duration);
  }

  void showWarning(String message, {Duration? duration}) {
    _add(message, NotificationType.warning, duration: duration);
  }
}

final notificationProvider = NotifierProvider<NotificationController, List<AppNotification>>(() {
  return NotificationController();
});
