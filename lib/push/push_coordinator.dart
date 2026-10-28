import 'dart:async';
import 'dart:developer' as dev;

import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:muuvie/push/push_route.dart';
import 'package:profile/profile.dart';
import 'package:social_network/social_network.dart';

/// Push on the app side (fase 15): once a user is signed in, asks for the
/// permission (D5), registers the token and keeps it fresh, tags the crash
/// reports and analytics with the account id, and opens the screen of a
/// tapped notification.
class PushCoordinator {
  final PushMessaging _push;
  final RegisterPushDevice _registerDevice;
  final Stream<UserProfile> _profiles;
  final Stream<void> _sessionEnded;
  final void Function(PageRouteInfo route) _open;

  final _subscriptions = <StreamSubscription<Object?>>[];
  String? _userId;

  PushCoordinator({
    required PushMessaging push,
    required RegisterPushDevice registerDevice,
    required Stream<UserProfile> profiles,
    required Stream<void> sessionEnded,
    required void Function(PageRouteInfo route) open,
  }) : _push = push,
       _registerDevice = registerDevice,
       _profiles = profiles,
       _sessionEnded = sessionEnded,
       _open = open;

  Future<void> start() async {
    _subscriptions
      ..add(_profiles.listen(_onProfile, onError: (Object _) {}))
      ..add(_sessionEnded.listen((_) => _signedOut()))
      ..add(_push.onTokenRefresh.listen((_) => _register()))
      ..add(_push.onNotificationOpened.listen(_onOpened));
    final initial = await _push.initialNotification();
    if (initial != null) _onOpened(initial);
  }

  Future<void> _onProfile(UserProfile profile) async {
    if (profile.id.isEmpty || profile.id == _userId) return;
    _userId = profile.id;
    await Telemetry.crashes.setUserId(profile.id);
    await Telemetry.analytics.setUserId(profile.id);
    await _push.requestPermission();
    await _register();
  }

  Future<void> _register() async {
    if (_userId == null) return;
    final locale = Intl.getCurrentLocale();
    final result = await _registerDevice(locale);
    if (result case Failure(:final error)) {
      dev.log('[Push] Could not register the device: $error');
    }
  }

  /// After logout the next sign-in registers again, even with the same user.
  /// The token itself was removed by the logout (LogoutWithPush).
  void _signedOut() {
    _userId = null;
    Telemetry.crashes.setUserId(null);
    Telemetry.analytics.setUserId(null);
  }

  void _onOpened(PushNotification push) {
    final route = pushRoute(push);
    Telemetry.analytics.logEvent('push_opened', {'type': push.type});
    if (route != null) _open(route);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
