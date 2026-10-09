import 'package:public_profile_domain/models/following_user.dart';

sealed class FriendsState {
  const FriendsState();
}

class FriendsLoading extends FriendsState {
  const FriendsLoading();
}

class FriendsSuccess extends FriendsState {
  final List<FollowingUser> users;

  const FriendsSuccess(this.users);
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);
}
