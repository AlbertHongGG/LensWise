enum NotificationType { success, error, warning, info }

class InAppNotification {
  final String id;
  final String message;
  final String? title;
  final NotificationType type;

  InAppNotification({
    required this.id,
    required this.message,
    this.title,
    this.type = NotificationType.info,
  });
}
