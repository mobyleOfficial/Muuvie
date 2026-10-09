import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';

import 'package:profile_ui/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ObserveUserProfile _getUserProfile;
  final RefreshUserProfile _refreshUserProfile;
  StreamSubscription<UserProfile>? _subscription;

  ProfileCubit({
    required ObserveUserProfile getUserProfile,
    required RefreshUserProfile refreshUserProfile,
  }) : _getUserProfile = getUserProfile,
       _refreshUserProfile = refreshUserProfile,
       super(const ProfileLoading()) {
    dev.log('[ProfileWS] Profile stream started');
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _getUserProfile().listen(
      (profile) {
        emit(ProfileSuccess(profile));
        dev.log('[ProfileWS] State emitted: ${profile.moviesWatchedCount}');
      },
      onError: (error) {
        emit(const ProfileError(""));
      },
      onDone: () {
        dev.log('[ProfileWS] Profile stream closed (onDone)');
      },
    );
  }

  void retry() {
    emit(const ProfileLoading());
    _refreshUserProfile();
  }

  void updateProfile(UserProfile updated) {
    final current = state;
    if (current is ProfileSuccess) {
      emit(
        ProfileSuccess(
          current.profile.copyWith(
            photoUrl: updated.photoUrl,
            username: updated.username,
            bio: updated.bio,
          ),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
