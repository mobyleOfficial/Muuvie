import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_profile/public_profile_info/public_profile_info_state.dart';
import 'package:public_profile_domain/usecases/follow_user.dart';
import 'package:public_profile_domain/usecases/get_public_profile.dart';
import 'package:public_profile_domain/usecases/unfollow_user.dart';

class PublicProfileInfoCubit extends Cubit<PublicProfileInfoState> {
  final GetPublicProfile _getPublicProfile;
  final FollowUser _followUser;
  final UnfollowUser _unfollowUser;
  final String userId;

  PublicProfileInfoCubit({
    required GetPublicProfile getPublicProfile,
    required FollowUser followUser,
    required UnfollowUser unfollowUser,
    required this.userId,
  }) : _getPublicProfile = getPublicProfile,
       _followUser = followUser,
       _unfollowUser = unfollowUser,
       super(const PublicProfileInfoLoading()) {
    _load();
  }

  Future<void> _load() async {
    final result = await _getPublicProfile(userId);

    switch (result) {
      case Success(:final data):
        emit(PublicProfileInfoSuccess(data));
      case Failure(:final error):
        emit(PublicProfileInfoError(error.message));
    }
  }

  void reload() => _load();

  Future<void> toggleFollow() async {
    final current = state;
    if (current is! PublicProfileInfoSuccess) return;

    final profile = current.profile;
    final wasFollowing = profile.isFollowing;

    // Optimistic update
    emit(
      PublicProfileInfoSuccess(profile.copyWith(isFollowing: !wasFollowing)),
    );

    final result = wasFollowing
        ? await _unfollowUser(userId)
        : await _followUser(userId);

    if (result is Failure) {
      // Revert on error
      emit(
        PublicProfileInfoSuccess(profile.copyWith(isFollowing: wasFollowing)),
      );
    }
  }
}
