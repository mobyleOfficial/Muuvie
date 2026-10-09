import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_profile_domain/models/following_user.dart';
import 'package:public_profile_domain/usecases/follow_user.dart';
import 'package:public_profile_domain/usecases/get_my_following.dart';
import 'package:public_profile_domain/usecases/unfollow_user.dart';
import 'package:social/tabs/friends/friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  final GetMyFollowing _getMyFollowing;
  final FollowUser _followUser;
  final UnfollowUser _unfollowUser;

  FriendsCubit({
    required GetMyFollowing getMyFollowing,
    required FollowUser followUser,
    required UnfollowUser unfollowUser,
  }) : _getMyFollowing = getMyFollowing,
       _followUser = followUser,
       _unfollowUser = unfollowUser,
       super(const FriendsLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const FriendsLoading());
    final result = await _getMyFollowing();
    switch (result) {
      case Success(:final data):
        emit(FriendsSuccess(data));
      case Failure(:final error):
        emit(FriendsError(error.message));
    }
  }

  Future<void> toggleFollow(FollowingUser user) async {
    final current = state;
    if (current is! FriendsSuccess) return;

    final updated = current.users.map((u) {
      if (u.id != user.id) return u;
      return FollowingUser(
        id: u.id,
        displayName: u.displayName,
        initials: u.initials,
        moviesWatchedCount: u.moviesWatchedCount,
        isFollowing: !u.isFollowing,
      );
    }).toList();

    emit(FriendsSuccess(updated));

    final result = user.isFollowing
        ? await _unfollowUser(user.id)
        : await _followUser(user.id);

    if (result is Failure) {
      // Revert
      emit(current);
    }
  }
}
