import 'package:movies_data/models/remote/remote_movie.dart';
import 'package:movies_domain/domain.dart';

/// One entry of `GET /movies/{id}/similar`: the movie of `results` and its
/// entry of `affinities`, matched by id. A backend without `affinities`
/// leaves [score] null.
class RemoteSimilarMovie {
  final RemoteMovie movie;
  final double? score;
  final List<String> sharedGenres;
  final List<String> sharedKeywords;
  final List<String> genres;

  const RemoteSimilarMovie({
    required this.movie,
    this.score,
    this.sharedGenres = const [],
    this.sharedKeywords = const [],
    this.genres = const [],
  });

  static List<RemoteSimilarMovie> listFromJson(Map<String, dynamic> json) {
    final affinitiesById = {
      for (final affinity
          in (json['affinities'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>())
        affinity['movieId'] as int: affinity,
    };
    return (json['results'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((movieJson) {
          final movie = RemoteMovie.fromJson(movieJson);
          final affinity = affinitiesById[movie.id];
          return RemoteSimilarMovie(
            movie: movie,
            score: (affinity?['score'] as num?)?.toDouble(),
            sharedGenres: _strings(affinity?['sharedGenres']),
            sharedKeywords: _strings(affinity?['sharedKeywords']),
            genres: _strings(affinity?['genres']),
          );
        })
        .toList();
  }

  static List<String> _strings(Object? json) =>
      (json as List<dynamic>? ?? const []).cast<String>();

  /// [rank] and [count] give the neutral score when the backend sent none.
  SimilarMovie toDomain({required int rank, required int count}) =>
      SimilarMovie(
        movie: movie.toDomain(),
        score: (score ?? SimilarMovie.neutralScore(rank, count)).clamp(0, 1),
        sharedGenres: sharedGenres,
        sharedKeywords: sharedKeywords,
        genres: genres,
      );
}
