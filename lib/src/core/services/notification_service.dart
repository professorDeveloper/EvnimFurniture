import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../di/injection.dart';
import '../network/dio_client.dart';

/// Handles FCM setup, foreground notifications, token registration, and tap routing.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localPlugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Bildirishnomalar',
    importance: Importance.high,
  );

  /// Global navigation key — set this from MaterialApp.
  static final navigatorKey = GlobalNavigatorKey();

  /// Initialize everything. Call once from main.dart after Firebase.initializeApp.
  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications setup
    await _localPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleTap(response.payload);
      },
    );

    // Create Android channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS foreground presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _handleTap(msg.data['type']);
    });

    // Terminated tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleTap(initial.data['type']);
    }
  }

  /// Register FCM token with backend. Call after login and on app start.
  Future<void> registerToken() async {
    final fcmToken = await _messaging.getToken();
    if (fcmToken == null) return;
    await _sendTokenToBackend(fcmToken);
  }

  /// Listen for token refreshes and re-register.
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      _sendTokenToBackend(newToken);
    });
  }

  /// Delete FCM token from backend. Call before logout.
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
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
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
    // Navigation based on type can be added later
    // e.g. navigatorKey.push('/notifications')
  }
}

/// Simple holder for a global navigator key.
class GlobalNavigatorKey {
  // Can be extended with actual navigation logic later.
}
