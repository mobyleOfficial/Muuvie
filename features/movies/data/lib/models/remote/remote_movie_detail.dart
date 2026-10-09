import 'package:movies_data/models/remote/remote_movie.dart';
import 'package:movies_data/models/remote/remote_movie_review.dart';
import 'package:movies_domain/domain.dart';

class RemoteMovieDetail {
  final int id;
  final String title;
  final String? localTitle;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final String tagline;
  final int? runtime;
  final List<String> genres;
  final String? director;
  final List<String>? cast;
  final List<RemoteWatchProvider>? watchProviders;
  final List<RemoteMovie>? similarMovies;
  final List<RemoteMovieReview>? popularReviews;
  final int? reviewCount;
  final int? listCount;
  final int? likeCount;
  final bool? likedByMe;

  const RemoteMovieDetail({
    required this.id,
    required this.title,
    this.localTitle,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.tagline,
    required this.runtime,
    required this.genres,
    this.director,
    this.cast,
    this.watchProviders,
    this.similarMovies,
    this.popularReviews,
    this.reviewCount,
    this.listCount,
    this.likeCount,
    this.likedByMe,
  });

  factory RemoteMovieDetail.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genres'] as List<dynamic>? ?? [];
    final genres = rawGenres.isEmpty
        ? <String>[]
        : rawGenres.first is String
        ? rawGenres.cast<String>()
        : rawGenres
              .cast<Map<String, dynamic>>()
              .map((g) => g['name'] as String)
              .toList();

    return RemoteMovieDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      localTitle: (json['localTitle'] ?? json['local_title']) as String?,
      overview: json['overview'] as String,
      posterPath: (json['posterPath'] ?? json['poster_path']) as String? ?? '',
      backdropPath:
          (json['backdropPath'] ?? json['backdrop_path']) as String? ?? '',
      voteAverage:
          ((json['voteAverage'] ?? json['vote_average']) as num?)?.toDouble() ??
          0.0,
      releaseDate:
          (json['releaseDate'] ?? json['release_date']) as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      runtime: json['runtime'] as int?,
      genres: genres,
      director: _parseDirector(json['director']),
      cast: _parseCast(json['cast']),
      watchProviders: (json['watchProviders'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(RemoteWatchProvider.fromJson)
          .toList(),
      similarMovies: (json['similarMovies'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(RemoteMovie.fromJson)
          .toList(),
      popularReviews: (json['popularReviews'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map(RemoteMovieReview.fromJson)
          .toList(),
      reviewCount: json['reviewCount'] as int?,
      listCount: json['listCount'] as int?,
      likeCount: json['likeCount'] as int?,
      likedByMe: json['likedByMe'] as bool?,
    );
  }

  static String? _parseDirector(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is Map<String, dynamic>) return raw['name'] as String?;
    return null;
  }

  static List<String>? _parseCast(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    if (raw.isEmpty) return [];
    if (raw.first is String) return raw.cast<String>();
    return raw
        .cast<Map<String, dynamic>>()
        .map((c) => c['name'] as String? ?? c['character'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Movie toDomain() => Movie(
    id: id,
    title: title,
    localTitle: localTitle,
    posterPath: posterPath,
    info: MovieInfo(
      overview: overview,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      tagline: tagline,
      runtime: runtime ?? 0,
      genres: genres,
      director: director ?? '',
      cast: cast ?? const [],
      watchProviders:
          watchProviders?.map((provider) => provider.toDomain()).toList() ??
          const [],
      similarMovies:
          similarMovies?.map((movie) => movie.toDomain()).toList() ?? const [],
      popularReviews:
          popularReviews?.map((review) => review.toDomain()).toList() ??
          const [],
      reviewCount: reviewCount ?? 0,
      listCount: listCount ?? 0,
      likeCount: likeCount ?? 0,
      isLikedByCurrentUser: likedByMe ?? false,
    ),
  );
}

class RemoteWatchProvider {
  final String name;
  final String logoPath;

  const RemoteWatchProvider({required this.name, required this.logoPath});

  factory RemoteWatchProvider.fromJson(Map<String, dynamic> json) =>
      RemoteWatchProvider(
        name: json['name'] as String,
        logoPath: (json['logoPath'] ?? json['logo_path']) as String? ?? '',
      );

  WatchProvider toDomain() => WatchProvider(name: name, logoPath: logoPath);
}
