import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../general/messenger.dart';

final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(ref);
});

class FCMService {
  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  FCMService(this._ref);

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Subscribe to topic
      await _messaging.subscribeToTopic('all');

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message interaction when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _ref.read(messengerProvider).showInfo(
            message.notification?.title ?? 'Notification',
            duration: const Duration(seconds: 5),
          );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle message opened from background state
  }
}
