class FollowingUser {
  final String id;
  final String displayName;
  final String initials;
  final int moviesWatchedCount;
  final bool isFollowing;

  const FollowingUser({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.moviesWatchedCount,
    this.isFollowing = true,
  });
}
