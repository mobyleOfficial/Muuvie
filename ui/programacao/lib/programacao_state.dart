sealed class ProgramacaoState {
  const ProgramacaoState();
}

class ProgramacaoLoading extends ProgramacaoState {
  const ProgramacaoLoading();
}

/// Maratonas (phase 7) and CineClubes (phase 8) lists.
/// [participatingOnly] narrows both to what the user joined.
class ProgramacaoSuccess extends ProgramacaoState {
  final bool participatingOnly;

  const ProgramacaoSuccess({this.participatingOnly = false});
}

class ProgramacaoError extends ProgramacaoState {
  final String message;

  const ProgramacaoError(this.message);
}
