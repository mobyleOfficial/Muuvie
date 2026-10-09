import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/movie_review.dart';
import 'package:movies_domain/models/watch_provider.dart';

class MovieInfo {
  final String overview;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String tagline;
  final int runtime;
  final List<String> genres;
  final String director;
  final List<String> cast;
  final List<WatchProvider> watchProviders;
  final List<Movie> similarMovies;
  final List<MovieReview> popularReviews;
  final int reviewCount;
  final int listCount;
  final int likeCount;
  final bool isLikedByCurrentUser;
  final double? userRating;
  final String? watchStatus;

  const MovieInfo({
    required this.overview,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.tagline = '',
    this.runtime = 0,
    this.genres = const [],
    this.director = '',
    this.cast = const [],
    this.watchProviders = const [],
    this.similarMovies = const [],
    this.popularReviews = const [],
    this.reviewCount = 0,
    this.listCount = 0,
    this.likeCount = 0,
    this.isLikedByCurrentUser = false,
    this.userRating,
    this.watchStatus,
  });

  MovieInfo copyWith({
    int? likeCount,
    bool? isLikedByCurrentUser,
    double? Function()? userRating,
    String? Function()? watchStatus,
  }) =>
      MovieInfo(
        overview: overview,
        backdropPath: backdropPath,
        voteAverage: voteAverage,
        releaseDate: releaseDate,
        tagline: tagline,
        runtime: runtime,
        genres: genres,
        director: director,
        cast: cast,
        watchProviders: watchProviders,
        similarMovies: similarMovies,
        popularReviews: popularReviews,
        reviewCount: reviewCount,
        listCount: listCount,
        likeCount: likeCount ?? this.likeCount,
        isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
        userRating: userRating != null ? userRating() : this.userRating,
        watchStatus: watchStatus != null ? watchStatus() : this.watchStatus,
      );
}
