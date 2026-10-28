import 'package:movies_domain/models/cast_member.dart';
import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/person.dart';
import 'package:movies_domain/models/watch_provider.dart';

class MovieInfo {
  final String overview;
  final String backdropPath;
  final String releaseDate;
  final String tagline;
  final int runtime;
  final List<String> genres;
  final String director;

  /// Database id of the director, when the backend knows the person (F5.7).
  final int? directorId;
  final List<CastMember> cast;

  /// Screenplay, writer and story credits.
  final List<Person> writers;

  /// YouTube key of the official trailer, when TMDB has one.
  final String? trailerKey;
  final List<WatchProvider> watchProviders;
  final List<Movie> similarMovies;

  const MovieInfo({
    required this.overview,
    required this.backdropPath,
    required this.releaseDate,
    this.tagline = '',
    this.runtime = 0,
    this.genres = const [],
    this.director = '',
    this.directorId,
    this.cast = const [],
    this.writers = const [],
    this.trailerKey,
    this.watchProviders = const [],
    this.similarMovies = const [],
  });
}
