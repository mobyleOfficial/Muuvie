import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

sealed class MovieWatchState {
  const MovieWatchState();
}

class MovieWatchLoading extends MovieWatchState {
  const MovieWatchLoading();
}

/// Not signed in: actions go through the auth gate first.
class MovieWatchGuest extends MovieWatchState {
  const MovieWatchGuest();
}

class MovieWatchError extends MovieWatchState {
  final String message;

  const MovieWatchError(this.message);
}

class MovieWatchReady extends MovieWatchState {
  final MovieUserState userState;
  final bool isBusy;

  const MovieWatchReady(this.userState, {this.isBusy = false});
}

/// The current user's state for one movie and its quick actions (F2.1, F2.4–F2.7).
/// Every write reloads the state, since one action can change several fields
/// (a completed session moves shelves, clears "assistindo agora"...).
class MovieWatchCubit extends Cubit<MovieWatchState> {
  final int movieId;
  final GetMovieWatchState _getMovieWatchState;
  final LogWatchSession _logWatchSession;
  final StartRewatch _startRewatch;
  final SetWatchingNow _setWatchingNow;

  MovieWatchCubit({
    required this.movieId,
    required GetMovieWatchState getMovieWatchState,
    required LogWatchSession logWatchSession,
    required StartRewatch startRewatch,
    required SetWatchingNow setWatchingNow,
  }) : _getMovieWatchState = getMovieWatchState,
       _logWatchSession = logWatchSession,
       _startRewatch = startRewatch,
       _setWatchingNow = setWatchingNow,
       super(const MovieWatchLoading()) {
    load();
  }

  Future<void> load() async {
    final result = await _getMovieWatchState(movieId);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => MovieWatchReady(data),
      Failure(error: AppError.unauthorized) => const MovieWatchGuest(),
      Failure(:final error) => MovieWatchError(error.message),
    });
  }

  /// The one-tap "Já assisti": a session with today's date only (F2.1).
  Future<bool> markWatched({DateTime? today}) {
    final now = today ?? DateTime.now();
    return _run(
      () => _logWatchSession(
        LogWatchSessionParams(
          movieId: movieId,
          draft: WatchLogDraft.watchedOn(
            DateTime(now.year, now.month, now.day),
          ),
        ),
      ),
    );
  }

  Future<bool> startRewatch() => _run(() => _startRewatch(movieId));

  Future<bool> toggleWatchingNow() {
    final current = state;
    if (current is! MovieWatchReady) return Future.value(false);
    return _run(
      () => _setWatchingNow(current.userState.watchingNow ? null : movieId),
    );
  }

  Future<bool> _run(Future<Result<Object?>> Function() action) async {
    final current = state;
    if (current is MovieWatchReady) {
      emit(MovieWatchReady(current.userState, isBusy: true));
    }
    final result = await action();
    if (isClosed) return false;
    await load();
    return result is Success;
  }
}
