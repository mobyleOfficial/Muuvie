import 'package:core/telemetry/push_notification.dart';

/// The device side of push notifications (fase 15): permission, the token the
/// backend sends to, and the notifications the user opens.
abstract class PushMessaging {
  /// `android`, `ios` or `web`, as `PUT /users/me/devices` expects.
  String get platform;

  /// Asks the system for permission; answers whether notifications are allowed.
  Future<bool> requestPermission();

  Future<bool> isPermitted();

  Future<String?> token();

  Stream<String> get onTokenRefresh;

  /// The notification that opened the app from closed, if any.
  Future<PushNotification?> initialNotification();

  /// Notifications tapped while the app was in the background.
  Stream<PushNotification> get onNotificationOpened;

  Future<void> deleteToken();
}
