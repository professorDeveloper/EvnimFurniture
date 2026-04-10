import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../di/injection.dart';
import '../network/dio_client.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localPlugin = FlutterLocalNotificationsPlugin();
  bool _permissionGranted = false;

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Bildirishnomalar',
    importance: Importance.high,
  );

  /// Initialize local notifications and listeners.
  /// Does NOT request permission — call [requestPermission] separately.
  Future<void> init() async {
    await _localPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleTap(response.payload);
      },
    );

    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleTap(msg.data['type']);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleTap(initial.data['type']);
    }

    // Check if already granted (e.g. user accepted before)
    final settings = await _messaging.getNotificationSettings();
    _permissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permission from the user.
  /// Returns true if granted.
  Future<bool> requestPermission() async {
    if (_permissionGranted) return true;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _permissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized;

    if (_permissionGranted) {
      await registerToken();
      listenTokenRefresh();
    }

    return _permissionGranted;
  }

  bool get isPermissionGranted => _permissionGranted;

  Future<void> registerToken() async {
    final fcmToken = await _messaging.getToken();
    if (fcmToken == null) return;
    await _sendTokenToBackend(fcmToken);
  }

  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });
  }

  Future<void> unregisterToken() async {
    final fcmToken = await _messaging.getToken();
    if (fcmToken == null) return;
    try {
      await sl<DioClient>().dio.delete(
        '/api/auth/fcm-token',
        data: {'token': fcmToken},
      );
    } catch (_) {}
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await sl<DioClient>().dio.post(
        '/api/auth/fcm-token',
        data: {'token': token},
      );
    } catch (_) {}
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localPlugin.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['type'],
    );
  }

  void _handleTap(String? type) {
    // Can be extended with navigation logic later
  }
}
