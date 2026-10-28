import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

/// The current user's state for a movie (F2.7).
class GetMovieWatchState extends UseCase<int, Result<MovieUserState>> {
  final WatchLogsRepository _repository;

  GetMovieWatchState(this._repository);

  @override
  Future<Result<MovieUserState>> call([int? movieId]) =>
      _repository.getMovieState(movieId!);
}

class SetMovieRatingParams {
  final int movieId;
  final RatingDraft draft;

  const SetMovieRatingParams({required this.movieId, required this.draft});
}

/// Rates with one label (phase 13). Abandonei and Na geladeira cannot create
/// the 100% session.
class SetMovieRating
    extends UseCase<SetMovieRatingParams, Result<MovieRating>> {
  final WatchLogsRepository _repository;

  SetMovieRating(this._repository);

  @override
  Future<Result<MovieRating>> call([SetMovieRatingParams? params]) async {
    final value = params!;
    if (value.draft.emotions.toSet().length > Emotion.maxPerLog ||
        (value.draft.createLog && !value.draft.rating.isVerdict)) {
      return const Failure(AppError.badRequest);
    }
    return _repository.rate(value.movieId, value.draft);
  }
}

/// Removes the rating label and the review; sessions and shelves stay.
class RemoveMovieRating extends UseCase<int, Result<void>> {
  final WatchLogsRepository _repository;

  RemoveMovieRating(this._repository);

  @override
  Future<Result<void>> call([int? movieId]) =>
      _repository.removeRating(movieId!);
}

/// Sets the movie shown as "assistindo agora" on the profile, or clears it
/// with null (F2.6).
class SetWatchingNow extends UseCase<int?, Result<void>> {
  final WatchLogsRepository _repository;

  SetWatchingNow(this._repository);

  @override
  Future<Result<void>> call([int? movieId]) =>
      _repository.setWatchingNow(movieId);
}

/// What a user is watching now, or null (F2.6).
class GetWatchingNow extends UseCase<String, Result<WatchingNow?>> {
  final WatchLogsRepository _repository;

  GetWatchingNow(this._repository);

  @override
  Future<Result<WatchingNow?>> call([String? userId]) =>
      _repository.getWatchingNow(userId!);
}
