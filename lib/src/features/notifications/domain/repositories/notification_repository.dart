import '../model/notification_item.dart';

abstract class NotificationRepository {
  Future<NotificationPage> getNotifications({int page = 1, int limit = 20});
}
