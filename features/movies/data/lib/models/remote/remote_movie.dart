import 'package:core/core.dart';
import 'package:movies_domain/domain.dart';

class RemoteMovie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final MovieListState? me;

  const RemoteMovie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    this.me,
  });

  factory RemoteMovie.fromJson(Map<String, dynamic> json) => RemoteMovie(
    id: json['id'] as int,
    title: json['title'] as String,
    overview: json['overview'] as String,
    posterPath: (json['posterPath'] ?? json['poster_path']) as String? ?? '',
    backdropPath:
        (json['backdropPath'] ?? json['backdrop_path']) as String? ?? '',
    releaseDate: (json['releaseDate'] ?? json['release_date']) as String? ?? '',
    me: _me(json['me']),
  );

  static MovieListState? _me(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final status = WatchStatus.fromWireValue(json['status'] as String?);
    final rating = Rating.fromWireValue(json['rating'] as String?);
    if (status == null && rating == null) return null;
    return MovieListState(status: status, rating: rating);
  }

  Movie toDomain() => Movie(
    id: id,
    title: title,
    posterPath: posterPath,
    info: MovieInfo(
      overview: overview,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
    ),
    me: me,
  );
}
