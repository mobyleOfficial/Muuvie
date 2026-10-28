import 'package:gamification/gamification.dart';

sealed class PosterGameState {
  const PosterGameState();
}

class PosterGameLoading extends PosterGameState {
  final int score;
  final int streak;
  final int rounds;

  const PosterGameLoading({this.score = 0, this.streak = 0, this.rounds = 0});
}

class PosterGameError extends PosterGameState {
  const PosterGameError();
}

/// A round being played. [answer] is the option picked, null until then.
class PosterGamePlaying extends PosterGameState {
  final PosterRound round;
  final int? answer;
  final int score;
  final int streak;
  final int rounds;

  const PosterGamePlaying({
    required this.round,
    this.answer,
    this.score = 0,
    this.streak = 0,
    this.rounds = 0,
  });

  bool get answered => answer != null;

  bool get correct => answer == round.movie.movieId;
}
