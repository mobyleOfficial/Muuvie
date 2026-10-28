import 'package:cineclubes_domain/models/cineclube.dart';

/// What the CineClube editor sends (F8.5). One session is a simple
/// CineClube, more make a cycle (F8.6). A null [password] keeps the current
/// one.
class CineClubeForm {
  final String slug;
  final String title;
  final String? description;
  final String? accentColor;
  final String? password;
  final bool removePassword;
  final String? debateLink;
  final String? socialLink;
  final List<SessionForm> sessions;

  const CineClubeForm({
    required this.slug,
    required this.title,
    this.description,
    this.accentColor,
    this.password,
    this.removePassword = false,
    this.debateLink,
    this.socialLink,
    this.sessions = const [],
  });

  /// The form of a stored CineClube, to edit it.
  factory CineClubeForm.of(CineClube cineclube) => CineClubeForm(
    slug: cineclube.slug,
    title: cineclube.title,
    description: cineclube.description,
    accentColor: cineclube.accentColor,
    debateLink: cineclube.debateLink,
    socialLink: cineclube.socialLink,
    sessions: [
      for (final session in cineclube.sessions)
        SessionForm(
          id: session.id,
          movie: session.movie,
          startsOn: session.startsOn,
          endsOn: session.endsOn,
          debateOn: session.debateOn,
        ),
    ],
  );
}

/// A session of the form. [movie] carries the database id; a movie known
/// only on TMDB goes by [CineClubeMovie.tmdbId] with id 0.
class SessionForm {
  final int? id;
  final CineClubeMovie movie;
  final DateTime startsOn;
  final DateTime endsOn;
  final DateTime debateOn;

  const SessionForm({
    this.id,
    required this.movie,
    required this.startsOn,
    required this.endsOn,
    required this.debateOn,
  });
}
