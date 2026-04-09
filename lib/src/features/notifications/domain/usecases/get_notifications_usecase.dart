import '../model/notification_item.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  Future<NotificationPage> call({int page = 1}) =>
      _repository.getNotifications(page: page);
}
