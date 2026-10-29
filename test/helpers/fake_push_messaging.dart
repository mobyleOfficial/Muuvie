import 'dart:async';

import 'package:core/core.dart';

/// Hand-rolled [PushMessaging]: the test sets the permission, the token and
/// the initial notification, and plays token refreshes and taps.
class FakePushMessaging implements PushMessaging {
  bool permitted;
  bool grantOnRequest;
  String? currentToken;
  PushNotification? initial;
  int permissionRequests = 0;
  int tokenDeletions = 0;
  final refreshes = StreamController<String>.broadcast();
  final opened = StreamController<PushNotification>.broadcast();

  FakePushMessaging({
    this.permitted = false,
    this.grantOnRequest = true,
    this.currentToken = 'token-1',
    this.initial,
  });

  @override
  String get platform => 'android';

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grantOnRequest) permitted = true;
    return permitted;
  }

  @override
  Future<bool> isPermitted() async => permitted;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> get onTokenRefresh => refreshes.stream;

  @override
  Future<PushNotification?> initialNotification() async => initial;

  @override
  Stream<PushNotification> get onNotificationOpened => opened.stream;

  @override
  Future<void> deleteToken() async {
    tokenDeletions++;
    currentToken = null;
  }

  Future<void> dispose() async {
    await refreshes.close();
    await opened.close();
  }
}
