import 'dart:async';
import 'dart:developer' as dev;

import 'package:core/core.dart';
import 'package:profile_data/datasources/profile_remote_data_source.dart';
import 'package:profile_domain/models/user_profile.dart';
import 'package:profile_domain/repositories/profile_repository.dart';
import 'package:rxdart/rxdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final WebSocketClient _webSocketClient;

  final _profileSubject = BehaviorSubject<UserProfile>();

  ProfileRepositoryImpl(this._profileRemoteDataSource, this._webSocketClient) {
    fetchProfile();
    _listenToWebSocket();
  }

  @override
  Stream<UserProfile> watchProfile() {
    return _profileSubject.stream;
  }

  @override
  Future<void> fetchProfile() async {
    final result = await _profileRemoteDataSource.getUserProfile();

    switch (result) {
      case Success(:final data):
        _profileSubject.add(data);
      case Failure(:final error):
        _profileSubject.addError(error);
    }
  }

  void _listenToWebSocket() {
    _webSocketClient.messages.listen(
      (message) {
        dev.log('[ProfileWS] WS message received: ${message.type}');
        _handleWsMessage(message);
      },
      onError: (e) {
        dev.log('[ProfileWS] WS stream error: $e');
      },
    );
  }

  /// An import job changed: the banner follows whether it is still running, and
  /// the profile reloads when it ends so the counts and recent movies update.
  void _handleWsMessage(WsMessage message) {
    if (message.type != WsMessageType.importProgress) return;
    final status = message.data?['status'] as String?;
    dev.log('[ProfileWS] Import ${message.data?['jobId']} is $status');
    if (status == 'done') {
      fetchProfile();
      return;
    }
    if (_profileSubject.hasValue) {
      _profileSubject.add(
        _profileSubject.value.copyWith(
          isScraping: _runningStatuses.contains(status),
        ),
      );
    }
  }

  static const _runningStatuses = {'pending', 'reading', 'importing'};

  @override
  Future<Result<void>> updateUserProfile({
    required UserProfile profile,
  }) async => _profileRemoteDataSource.updateUserProfile(profile: profile);
}
