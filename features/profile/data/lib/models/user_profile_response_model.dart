import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/movie_info.dart';
import 'package:profile_domain/models/user_profile.dart';

class UserProfileResponseModel {
  final String id;
  final String photoUrl;
  final String username;
  final String bio;
  final int moviesWatchedCount;
  final int followingCount;
  final int followersCount;
  final List<RecentMovieModel> recentMovies;
  final bool isScraping;

  const UserProfileResponseModel({
    required this.id,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.moviesWatchedCount,
    required this.followingCount,
    required this.followersCount,
    required this.recentMovies,
    required this.isScraping,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      UserProfileResponseModel(
        id: json['id'] as String? ?? '',
        photoUrl: json['photoUrl'] as String? ?? '',
        username: json['username'] as String,
        bio: json['bio'] as String? ?? '',
        moviesWatchedCount: json['moviesWatchedCount'] as int? ?? 0,
        followingCount: json['followingCount'] as int? ?? 0,
        followersCount: json['followersCount'] as int? ?? 0,
        recentMovies: (json['recentMovies'] as List<dynamic>?)
                ?.map((e) =>
                    RecentMovieModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isScraping: json['isScraping'] as bool? ?? false,
      );

  UserProfile toDomain() => UserProfile(
        id: id,
        photoUrl: photoUrl,
        username: username,
        bio: bio,
        moviesWatchedCount: moviesWatchedCount,
        followingCount: followingCount,
        followersCount: followersCount,
        recentMovies: recentMovies.map((m) => m.toDomain()).toList(),
        isScraping: isScraping,
      );
}

class RecentMovieModel {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  const RecentMovieModel({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory RecentMovieModel.fromJson(Map<String, dynamic> json) =>
      RecentMovieModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        posterPath: json['posterPath'] as String? ?? '',
        overview: json['overview'] as String? ?? '',
        backdropPath: json['backdropPath'] as String? ?? '',
        voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? 0.0,
        releaseDate: json['releaseDate'] as String? ?? '',
      );

  Movie toDomain() => Movie(
        id: id,
        title: title,
        posterPath: posterPath,
        info: MovieInfo(
          overview: overview,
          backdropPath: backdropPath,
          voteAverage: voteAverage,
          releaseDate: releaseDate,
        ),
      );
}
