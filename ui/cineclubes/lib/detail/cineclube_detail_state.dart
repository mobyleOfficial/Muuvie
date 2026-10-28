import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';

sealed class CineClubeDetailState {
  const CineClubeDetailState();
}

class CineClubeDetailLoading extends CineClubeDetailState {
  const CineClubeDetailLoading();
}

class CineClubeDetailError extends CineClubeDetailState {
  final AppError error;

  const CineClubeDetailError(this.error);
}

/// The CineClube and the session the Progresso and Participantes tabs show
/// (the current one until the user picks another of a cycle). [busy] is true
/// while joining, leaving or cancelling.
class CineClubeDetailSuccess extends CineClubeDetailState {
  final CineClube cineclube;
  final int? sessionId;
  final bool busy;

  const CineClubeDetailSuccess({
    required this.cineclube,
    this.sessionId,
    this.busy = false,
  });

  CineClubeSession? get session =>
      cineclube.sessions.where((s) => s.id == sessionId).firstOrNull ??
      cineclube.currentSession;

  CineClubeDetailSuccess copyWith({
    CineClube? cineclube,
    int? sessionId,
    bool? busy,
  }) => CineClubeDetailSuccess(
    cineclube: cineclube ?? this.cineclube,
    sessionId: sessionId ?? this.sessionId,
    busy: busy ?? this.busy,
  );
}
