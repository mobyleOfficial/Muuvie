import 'package:profile/profile.dart';

sealed class MemberProfileState {
  const MemberProfileState();
}

class MemberProfileLoading extends MemberProfileState {
  const MemberProfileLoading();
}

class MemberProfileSuccess extends MemberProfileState {
  final ProfileDetails profile;

  /// A follow or unfollow is on its way; the button waits for it.
  final bool isFollowBusy;

  const MemberProfileSuccess(this.profile, {this.isFollowBusy = false});
}

class MemberProfileError extends MemberProfileState {
  final String message;

  /// The id or @handle does not exist (or is not visible).
  final bool notFound;

  const MemberProfileError(this.message, {this.notFound = false});
}
