import 'package:core/core.dart';
import 'package:movies_domain/models/movie_community.dart';

abstract interface class MovieCommunityRepository {
  /// [movieId] is the database id of the movie.
  Future<Result<MovieCommunity>> getCommunity(int movieId);

  Future<Result<MovieEvents>> getEvents(int movieId);

  /// Every CineClube with a session of the movie, finished ones included.
  Future<Result<MovieEventPage>> getCineClubes(int movieId, {int page = 1});

  /// Maratonas in which the movie completed a challenge for someone.
  Future<Result<MovieEventPage>> getMaratonas(int movieId, {int page = 1});

  /// The last [months] months, the current one included.
  Future<Result<MovieTimeline>> getTimeline(int movieId, {int months = 12});
}
