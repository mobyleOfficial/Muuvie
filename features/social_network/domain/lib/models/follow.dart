import 'package:social_network_domain/models/social_user.dart';

/// How the current user and another one follow each other (F6.3).
class FollowStatus {
  final bool following;
  final bool followedBy;

  const FollowStatus({required this.following, required this.followedBy});

  bool get mutual => following && followedBy;
}

/// A row of the followers and following lists, with the current user's
/// relation to that user.
class FollowCard {
  final SocialUser user;
  final FollowStatus status;

  /// The row is the current user.
  final bool self;
  final DateTime followedAt;

  const FollowCard({
    required this.user,
    required this.status,
    this.self = false,
    required this.followedAt,
  });

  FollowCard copyWith({FollowStatus? status}) => FollowCard(
    user: user,
    status: status ?? this.status,
    self: self,
    followedAt: followedAt,
  );
}

class FollowPage {
  final List<FollowCard> cards;
  final int page;
  final bool hasNext;

  const FollowPage({
    required this.cards,
    required this.page,
    required this.hasNext,
  });
}
