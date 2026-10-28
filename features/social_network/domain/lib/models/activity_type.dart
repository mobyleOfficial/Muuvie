/// What an activity of the feed says the user did (F6.1). Maratonas publish
/// from phase 7 and CineClubes from phase 8; the bichinho starts in phase 10.
enum ActivityType {
  watchSession('registro_sessao'),
  rating('avaliacao'),
  finishedMovie('concluiu_filme'),
  newShelf('nova_estante'),
  featuredShelf('estante_destaque'),
  newLocadora('nova_locadora'),
  joinedMaratona('entrou_maratona'),
  finishedChallenge('concluiu_desafio'),
  finishedMaratona('concluiu_maratona'),
  joinedCineclube('entrou_cineclube'),
  createdMaratona('criou_maratona'),
  createdCineclube('criou_cineclube'),
  unlockedBichinho('desbloquear_bichinho'),
  watchingNow('assistindo_agora'),
  importedMovies('importou_filmes');

  final String wireValue;

  const ActivityType(this.wireValue);

  static ActivityType? fromWireValue(String? value) =>
      values.where((type) => type.wireValue == value).firstOrNull;
}

/// Which slice of the feed the Atts tab shows (F6.2).
enum FeedScope {
  /// Me and the people I follow.
  all('all'),
  following('following'),
  me('me');

  final String wireValue;

  const FeedScope(this.wireValue);
}

/// Filter of a movie's activities (B13.3): Avaliações or Atualizações. Null
/// where it is taken means Tudo.
enum MovieActivityKind {
  /// Anything with a rating, alone or with a session.
  ratings('ratings'),

  /// Sessions and "assistindo agora".
  updates('updates');

  final String wireValue;

  const MovieActivityKind(this.wireValue);
}
