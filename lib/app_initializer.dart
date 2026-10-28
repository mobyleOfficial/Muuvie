import 'dart:async';
import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:muuvie/push/push_coordinator.dart';
import 'package:profile/profile.dart';

class AppInitializer {
  final WebSocketClient _webSocketClient;
  final ObserveUserProfile _getUserProfile;
  final PushCoordinator _pushCoordinator;

  StreamSubscription<UserProfile>? _profileSubscription;

  AppInitializer({
    required WebSocketClient webSocketClient,
    required ObserveUserProfile getUserProfile,
    required PushCoordinator pushCoordinator,
  }) : _webSocketClient = webSocketClient,
       _getUserProfile = getUserProfile,
       _pushCoordinator = pushCoordinator;

  Future<void> initialize() async {
    _profileSubscription = _getUserProfile().listen(
      (profile) => dev.log('[ProfileWS] Profile updated: ${profile.username}'),
      onError: (Object e) => dev.log('[ProfileWS] Profile stream error: $e'),
    );

    unawaited(
      _webSocketClient.connect().catchError(
        (Object e) => dev.log('[ProfileWS] WebSocket connect failed: $e'),
      ),
    );

    unawaited(_pushCoordinator.start());
  }

  Future<void> dispose() async {
    await _profileSubscription?.cancel();
    await _pushCoordinator.dispose();
    await _webSocketClient.dispose();
  }
}
