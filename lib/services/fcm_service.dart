import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {}

class FcmService {
  static const String _backendUrl =
      'https://clickmanager.space/api/device-tokens';

  // Called from main() — does NOT block app startup
  static void init() {
    _setup().catchError((e) {
      // ignore: avoid_print
      print('[FCM] init error: $e');
    });
  }

  static Future<void> _setup() async {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ignore: avoid_print
    print('[FCM] permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('[FCM] permission denied — no token will be obtained');
      return;
    }

    final token = await messaging.getToken();
    // ignore: avoid_print
    print('[FCM] token: $token');

    if (token != null) {
      await _sendTokenToBackend(token);
    }

    messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: {
          'fcm_token':   token,
          'platform':    Platform.isAndroid ? 'android' : 'ios',
          'device_name': Platform.isAndroid ? 'Android Device' : 'iOS Device',
          'project':     'flyz',
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
