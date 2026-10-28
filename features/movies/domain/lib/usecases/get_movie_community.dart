import 'package:core/core.dart';
import 'package:movies_domain/models/movie_community.dart';
import 'package:movies_domain/repositories/movie_community_repository.dart';

/// The community block of the movie detail (B13.2): ratings by label, how many
/// watched, want to watch or shelve it, and the emotions. [int] is the
/// database id.
class GetMovieCommunity extends UseCase<int, Result<MovieCommunity>> {
  final MovieCommunityRepository _repository;

  GetMovieCommunity(this._repository);

  @override
  Future<Result<MovieCommunity>> call([int? params]) =>
      _repository.getCommunity(params!);
}

/// Open maratonas the movie counts for and CineClubes that screen it (F12.1).
class GetMovieEvents extends UseCase<int, Result<MovieEvents>> {
  final MovieCommunityRepository _repository;

  GetMovieEvents(this._repository);

  @override
  Future<Result<MovieEvents>> call([int? params]) =>
      _repository.getEvents(params!);
}

class MovieEventPageParams {
  /// Database id of the movie.
  final int movieId;
  final int page;

  const MovieEventPageParams({required this.movieId, this.page = 1});
}

/// Every CineClube that screens or screened the movie (B13.5).
class GetMovieCineClubes
    extends UseCase<MovieEventPageParams, Result<MovieEventPage>> {
  final MovieCommunityRepository _repository;

  GetMovieCineClubes(this._repository);

  @override
  Future<Result<MovieEventPage>> call([MovieEventPageParams? params]) =>
      _repository.getCineClubes(params!.movieId, page: params.page);
}

/// Maratonas in which the movie completed a challenge (B13.5).
class GetMovieMaratonas
    extends UseCase<MovieEventPageParams, Result<MovieEventPage>> {
  final MovieCommunityRepository _repository;

  GetMovieMaratonas(this._repository);

  @override
  Future<Result<MovieEventPage>> call([MovieEventPageParams? params]) =>
      _repository.getMaratonas(params!.movieId, page: params.page);
}

/// Public sessions and ratings of the movie in the last 12 months (B13.5).
class GetMovieTimeline extends UseCase<int, Result<MovieTimeline>> {
  final MovieCommunityRepository _repository;

  GetMovieTimeline(this._repository);

  @override
  Future<Result<MovieTimeline>> call([int? params]) =>
      _repository.getTimeline(params!);
}
