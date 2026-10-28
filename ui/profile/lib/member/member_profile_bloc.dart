import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/profile.dart';
import 'package:social_network/social_network.dart';

import 'package:profile_ui/member/member_profile_state.dart';

/// Header of a profile (F5.1): the v1 profile with its counters and the follow
/// relation. [changes] reloads it, e.g. when an import of the own profile ends.
class MemberProfileCubit extends Cubit<MemberProfileState> {
  final String _userId;
  final GetProfileDetails _getProfile;
  final SetFollowing? _setFollowing;
  StreamSubscription<Object?>? _changes;

  MemberProfileCubit({
    required String userId,
    required GetProfileDetails getProfile,
    SetFollowing? setFollowing,
    Stream<Object?>? changes,
  }) : _userId = userId,
       _getProfile = getProfile,
       _setFollowing = setFollowing,
       super(const MemberProfileLoading()) {
    _changes = changes?.listen((_) => load());
    load();
  }

  Future<void> load() async {
    if (state is MemberProfileError) emit(const MemberProfileLoading());
    final result = await _getProfile(_userId);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => MemberProfileSuccess(data),
      Failure(:final error) => MemberProfileError(
        error.message,
        notFound: error == AppError.notFound,
      ),
    });
  }

  /// Follows or unfollows with an optimistic update (F6.3), then takes the
  /// relation the server answers. Reverts and answers the error when it fails.
  Future<AppError?> toggleFollow() async {
    final current = state;
    if (current is! MemberProfileSuccess || current.isFollowBusy) return null;
    final profile = current.profile;
    final follow = !profile.isFollowing;
    final updated = profile.copyWith(
      isFollowing: follow,
      mutual: follow && profile.followsMe,
      stats: profile.stats.copyWith(
        followers: profile.stats.followers + (follow ? 1 : -1),
      ),
    );
    emit(MemberProfileSuccess(updated, isFollowBusy: true));

    final result = await _setFollowing?.call(
      SetFollowingParams(userId: profile.id, follow: follow),
    );
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        emit(
          MemberProfileSuccess(
            updated.copyWith(
              isFollowing: data.following,
              followsMe: data.followedBy,
              mutual: data.mutual,
            ),
          ),
        );
        return null;
      case Failure(:final error):
        emit(MemberProfileSuccess(profile));
        return error;
      case null:
        emit(MemberProfileSuccess(profile));
        return AppError.unknown;
    }
  }

  @override
  Future<void> close() {
    _changes?.cancel();
    return super.close();
  }
}
