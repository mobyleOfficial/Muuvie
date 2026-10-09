import 'package:public_profile_data/models/remote/remote_profile_favorite_movie.dart';
import 'package:public_profile_data/models/remote/remote_profile_recent_activity.dart';
import 'package:public_profile_data/models/remote/remote_profile_user.dart';
import 'package:public_profile_data/models/remote/remote_profile_watched_movie.dart';
import 'package:public_profile_data/models/remote/remote_profile_watchlist_item.dart';
import 'package:public_profile_domain/models/public_profile.dart';

class RemotePublicProfile {
  final String id;
  final String displayName;
  final String initials;
  final String bio;
  final List<RemoteProfileWatchedMovie> moviesWatched;
  final List<RemoteProfileUser> following;
  final List<RemoteProfileUser> followers;
  final List<RemoteProfileFavoriteMovie> favoriteMovies;
  final List<RemoteProfileRecentActivity> recentActivities;
  final List<RemoteProfileWatchlistItem> watchlist;
  final bool isFollowing;

  const RemotePublicProfile({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.bio,
    required this.moviesWatched,
    required this.following,
    required this.followers,
    required this.favoriteMovies,
    required this.recentActivities,
    required this.watchlist,
    this.isFollowing = false,
  });

  factory RemotePublicProfile.fromJson(Map<String, dynamic> json) =>
      RemotePublicProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        initials: json['initials'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        moviesWatched:
            (json['movies_watched'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileWatchedMovie.fromJson)
                .toList() ??
            [],
        following:
            (json['following'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileUser.fromJson)
                .toList() ??
            [],
        followers:
            (json['followers'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileUser.fromJson)
                .toList() ??
            [],
        favoriteMovies:
            (json['favorite_movies'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileFavoriteMovie.fromJson)
                .toList() ??
            [],
        recentActivities:
            (json['recent_activities'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileRecentActivity.fromJson)
                .toList() ??
            [],
        watchlist:
            (json['watchlist'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>()
                .map(RemoteProfileWatchlistItem.fromJson)
                .toList() ??
            [],
        isFollowing: json['is_following'] as bool? ?? false,
      );

  PublicProfile toDomain() => PublicProfile(
    id: id,
    displayName: displayName,
    initials: initials,
    bio: bio,
    moviesWatched: moviesWatched.map((movie) => movie.toDomain()).toList(),
    following: following.map((user) => user.toDomain()).toList(),
    followers: followers.map((user) => user.toDomain()).toList(),
    favoriteMovies: favoriteMovies.map((movie) => movie.toDomain()).toList(),
    recentActivities: recentActivities
        .map((activity) => activity.toDomain())
        .toList(),
    watchlist: watchlist.map((item) => item.toDomain()).toList(),
    isFollowing: isFollowing,
  );
}
