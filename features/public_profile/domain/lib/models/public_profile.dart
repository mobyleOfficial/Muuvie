import 'package:public_profile_domain/models/profile_favorite_movie.dart';
import 'package:public_profile_domain/models/profile_recent_activity.dart';
import 'package:public_profile_domain/models/profile_user.dart';
import 'package:public_profile_domain/models/profile_watched_movie.dart';
import 'package:public_profile_domain/models/profile_watchlist_item.dart';

class PublicProfile {
  final String id;
  final String displayName;
  final String initials;
  final String bio;
  final List<ProfileWatchedMovie> moviesWatched;
  final List<ProfileUser> following;
  final List<ProfileUser> followers;
  final List<ProfileFavoriteMovie> favoriteMovies;
  final List<ProfileRecentActivity> recentActivities;
  final List<ProfileWatchlistItem> watchlist;
  final bool isFollowing;

  const PublicProfile({
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

  PublicProfile copyWith({
    String? id,
    String? displayName,
    String? initials,
    String? bio,
    List<ProfileWatchedMovie>? moviesWatched,
    List<ProfileUser>? following,
    List<ProfileUser>? followers,
    List<ProfileFavoriteMovie>? favoriteMovies,
    List<ProfileRecentActivity>? recentActivities,
    List<ProfileWatchlistItem>? watchlist,
    bool? isFollowing,
  }) {
    return PublicProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      initials: initials ?? this.initials,
      bio: bio ?? this.bio,
      moviesWatched: moviesWatched ?? this.moviesWatched,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      recentActivities: recentActivities ?? this.recentActivities,
      watchlist: watchlist ?? this.watchlist,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
