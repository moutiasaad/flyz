import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

const _kChannelId = 'flyz_high';
const _kChannelName = 'Flyz';
const _kChannelDesc = 'Vols, réservations et mises à jour Flyz';

const _androidChannel = AndroidNotificationChannel(
  _kChannelId,
  _kChannelName,
  description: _kChannelDesc,
  importance: Importance.high,
);

final _plugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // FCM auto-displays notification messages when app is background/terminated.
  // Data-only messages: show manually via local notifications.
  if (message.notification != null) return;
  await _plugin.show(
    message.hashCode,
    message.data['title'] as String? ?? 'Flyz',
    message.data['body'] as String? ?? '',
    NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

class FcmService {
  static const String _backendUrl =
      'https://clickmanager.space/api/device-tokens';

  static void init() {
    _setup().catchError((e) {
      // ignore: avoid_print
      print('[FCM] init error: $e');
    });
  }

  static Future<void> _setup() async {
    // Create the high-importance Android channel once
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialize the local notifications plugin
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ignore: avoid_print
    print('[FCM] permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // Foreground: FCM delivers silently — show via local notification instead
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] as String?;
      final body = notification?.body ?? message.data['body'] as String?;
      if (title == null && body == null) return;
      _plugin.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });

    final token = await messaging.getToken();
    // ignore: avoid_print
    print('[FCM] token: $token');

    if (token != null) await _sendTokenToBackend(token);
    messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: {
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'device_name': Platform.isAndroid ? 'Android Device' : 'iOS Device',
          'project': 'flyz',
        },
      );
      // ignore: avoid_print
      print('[FCM] backend response: ${response.statusCode} ${response.body}');
    } catch (e) {
      // ignore: avoid_print
      print('[FCM] backend error: $e');
    }
  }
}
