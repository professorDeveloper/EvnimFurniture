part of 'notification_bloc.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}
