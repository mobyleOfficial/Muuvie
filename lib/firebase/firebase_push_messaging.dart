import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Push through Firebase Cloud Messaging. With the app open nothing is shown:
/// the WebSocket already updates the screen and the badges (D6 of fase 15).
class FirebasePushMessaging implements PushMessaging {
  final FirebaseMessaging _messaging;

  FirebasePushMessaging(this._messaging);

  @override
  String get platform => switch (defaultTargetPlatform) {
    _ when kIsWeb => 'web',
    TargetPlatform.iOS || TargetPlatform.macOS => 'ios',
    _ => 'android',
  };

  @override
  Future<bool> requestPermission() async =>
      _allowed((await _messaging.requestPermission()).authorizationStatus);

  @override
  Future<bool> isPermitted() async => _allowed(
    (await _messaging.getNotificationSettings()).authorizationStatus,
  );

  // The registration token, which the backend sends to (FCM HTTP v1
  // `message.token`). The newer register() / onRegistered give an
  // installation id instead, so the backend would need another send path.
  @override
  // ignore: deprecated_member_use
  Future<String?> token() => _messaging.getToken();

  @override
  // ignore: deprecated_member_use
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<PushNotification?> initialNotification() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : PushNotification.fromData(message.data);
  }

  @override
  Stream<PushNotification> get onNotificationOpened => FirebaseMessaging
      .onMessageOpenedApp
      .map((message) => PushNotification.fromData(message.data));

  @override
  // ignore: deprecated_member_use
  Future<void> deleteToken() => _messaging.deleteToken();

  bool _allowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}
