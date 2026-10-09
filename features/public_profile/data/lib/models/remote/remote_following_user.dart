import 'package:public_profile_domain/models/following_user.dart';

class RemoteFollowingUser {
  final String id;
  final String displayName;
  final String initials;
  final int moviesWatchedCount;
  final bool isFollowing;

  const RemoteFollowingUser({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.moviesWatchedCount,
    this.isFollowing = true,
  });

  factory RemoteFollowingUser.fromJson(Map<String, dynamic> json) =>
      RemoteFollowingUser(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        initials: json['initials'] as String? ?? '',
        moviesWatchedCount: json['movies_watched_count'] as int? ?? 0,
        isFollowing: json['is_following'] as bool? ?? true,
      );

  FollowingUser toDomain() => FollowingUser(
    id: id,
    displayName: displayName,
    initials: initials,
    moviesWatchedCount: moviesWatchedCount,
    isFollowing: isFollowing,
  );
}
