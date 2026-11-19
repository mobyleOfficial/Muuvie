import 'dart:async';
import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:muuvie/push/push_coordinator.dart';
import 'package:profile/profile.dart';

/// Starts what runs for the whole app: the session profile, the WebSocket and
/// push. The WebSocket and the profile follow the session: a sign-in connects
/// and reloads them (which also registers push for the new account), a logout
/// disconnects, so no events of the previous account keep arriving.
class AppInitializer {
  final WebSocketClient _webSocketClient;
  final ObserveUserProfile _getUserProfile;
  final RefreshUserProfile? _refreshUserProfile;
  final PushCoordinator _pushCoordinator;
  final Stream<void> _sessionStarted;
  final Stream<void> _sessionEnded;

  final _subscriptions = <StreamSubscription<Object?>>[];

  AppInitializer({
    required WebSocketClient webSocketClient,
    required ObserveUserProfile getUserProfile,
    required PushCoordinator pushCoordinator,
    RefreshUserProfile? refreshUserProfile,
    Stream<void> sessionStarted = const Stream.empty(),
    Stream<void> sessionEnded = const Stream.empty(),
  }) : _webSocketClient = webSocketClient,
       _getUserProfile = getUserProfile,
       _refreshUserProfile = refreshUserProfile,
       _pushCoordinator = pushCoordinator,
       _sessionStarted = sessionStarted,
       _sessionEnded = sessionEnded;

  Future<void> initialize() async {
    _subscriptions
      ..add(
        _getUserProfile().listen(
          (profile) =>
              dev.log('[ProfileWS] Profile updated: ${profile.username}'),
          onError: (Object e) =>
              dev.log('[ProfileWS] Profile stream error: $e'),
        ),
      )
      ..add(_sessionStarted.listen((_) => _onSignedIn()))
      ..add(_sessionEnded.listen((_) => _webSocketClient.disconnect()));

    _connect();
    unawaited(_pushCoordinator.start());
  }

  void _onSignedIn() {
    unawaited(_refreshUserProfile?.call());
    _connect();
  }

  void _connect() => unawaited(
    _webSocketClient.connect().catchError(
      (Object e) => dev.log('[ProfileWS] WebSocket connect failed: $e'),
    ),
  );

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _pushCoordinator.dispose();
    await _webSocketClient.dispose();
  }
}
