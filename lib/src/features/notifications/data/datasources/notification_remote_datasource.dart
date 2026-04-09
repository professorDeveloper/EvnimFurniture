import '../../../../core/network/dio_client.dart';
import '../../domain/model/notification_item.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationPage> getNotifications({int page = 1, int limit = 20});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<NotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dioClient.dio.get(
      '/api/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return NotificationPage.fromJson(res.data as Map<String, dynamic>);
  }
}
