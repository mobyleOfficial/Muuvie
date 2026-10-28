import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/poster/poster_game_state.dart';

/// The poster game (F10.5), solo: guess the movie of a blurred poster.
/// A right answer scores more the sooner it comes; a wrong one ends the
/// streak.
class PosterGameCubit extends Cubit<PosterGameState> {
  static const maxPoints = 100;

  final GetPosterRound _getRound;

  PosterGameCubit({required GetPosterRound getRound})
    : _getRound = getRound,
      super(const PosterGameLoading());

  Future<void> next() async {
    final current = state;
    final (score, streak, rounds) = switch (current) {
      PosterGamePlaying() => (current.score, current.streak, current.rounds),
      PosterGameLoading() => (current.score, current.streak, current.rounds),
      PosterGameError() => (0, 0, 0),
    };
    emit(PosterGameLoading(score: score, streak: streak, rounds: rounds));
    final result = await _getRound();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => PosterGamePlaying(
        round: data,
        score: score,
        streak: streak,
        rounds: rounds,
      ),
      Failure() => const PosterGameError(),
    });
  }

  /// [clarity] is how sharp the poster was when answered, 0 to 1.
  void answer(int movieId, double clarity) {
    final current = state;
    if (current is! PosterGamePlaying || current.answered) return;
    final correct = movieId == current.round.movie.movieId;
    final points = correct ? (maxPoints * (1 - clarity * 0.8)).round() : 0;
    emit(
      PosterGamePlaying(
        round: current.round,
        answer: movieId,
        score: current.score + points,
        streak: correct ? current.streak + 1 : 0,
        rounds: current.rounds + 1,
      ),
    );
  }
}
