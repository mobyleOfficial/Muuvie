import 'dart:async';
import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:profile/profile.dart';

class AppInitializer {
  final WebSocketClient _webSocketClient;
  final ObserveUserProfile _getUserProfile;

  StreamSubscription<UserProfile>? _profileSubscription;

  AppInitializer({
    required WebSocketClient webSocketClient,
    required ObserveUserProfile getUserProfile,
  }) : _webSocketClient = webSocketClient,
       _getUserProfile = getUserProfile;

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
  }

  Future<void> dispose() async {
    await _profileSubscription?.cancel();
    await _webSocketClient.dispose();
  }
}
