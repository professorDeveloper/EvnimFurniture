import '../../domain/model/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required this.remoteDataSource});

  final NotificationRemoteDataSource remoteDataSource;

  @override
  Future<NotificationPage> getNotifications({int page = 1, int limit = 20}) =>
      remoteDataSource.getNotifications(page: page, limit: limit);
}
