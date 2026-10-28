import 'package:core/telemetry/push_messaging.dart';
import 'package:core/telemetry/push_notification.dart';

/// Used while Firebase is not configured, and in tests: no token, so nothing
/// is registered on the backend.
class NoopPushMessaging implements PushMessaging {
  const NoopPushMessaging();

  @override
  String get platform => 'android';

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> isPermitted() async => false;

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<PushNotification?> initialNotification() async => null;

  @override
  Stream<PushNotification> get onNotificationOpened => const Stream.empty();

  @override
  Future<void> deleteToken() async {}
}
