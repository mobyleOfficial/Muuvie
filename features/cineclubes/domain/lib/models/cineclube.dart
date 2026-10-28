import 'package:core/core.dart';

/// Where a CineClube is in its sessions. Upcoming and active ones take joins.
enum CineClubeStatus {
  upcoming('upcoming'),
  active('active'),
  finished('finished'),
  cancelled('cancelled');

  final String wireValue;

  const CineClubeStatus(this.wireValue);

  bool get open => this == upcoming || this == active;

  static CineClubeStatus fromWireValue(String? value) =>
      values.where((status) => status.wireValue == value).firstOrNull ??
      upcoming;
}

/// Where a participant is with the movie of a session, from their logs.
enum SessionProgress {
  pending('pending'),
  watching('watching'),
  completed('completed');

  final String wireValue;

  const SessionProgress(this.wireValue);

  static SessionProgress fromWireValue(String? value) =>
      values.where((progress) => progress.wireValue == value).firstOrNull ??
      pending;
}

/// A user as the CineClubes show them (owner, participants, logs).
class CineClubeUser {
  final String id;
  final String username;
  final String? handle;
  final String? displayName;
  final String? avatarUrl;
  final String? accentColor;

  const CineClubeUser({
    required this.id,
    required this.username,
    this.handle,
    this.displayName,
    this.avatarUrl,
    this.accentColor,
  });

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;
}

/// The movie of a session. [id] is the database id the app opens it with.
class CineClubeMovie {
  final int id;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? year;
  final int? runtime;

  const CineClubeMovie({
    required this.id,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.year,
    this.runtime,
  });
}

/// One movie of a CineClube, with its period and debate day.
class CineClubeSession {
  final int id;
  final int position;
  final CineClubeMovie movie;
  final DateTime startsOn;
  final DateTime endsOn;
  final DateTime debateOn;

  const CineClubeSession({
    required this.id,
    this.position = 0,
    required this.movie,
    required this.startsOn,
    required this.endsOn,
    required this.debateOn,
  });

  /// Started on [today] or before.
  bool startedBy(DateTime today) => !startsOn.isAfter(today);

  /// The debate day came: spoilers are open to everyone.
  bool debateCame(DateTime today) => !debateOn.isAfter(today);
}

/// A row of the CineClube list (F8.2); the movie and the debate are the
/// current session's.
class CineClubeSummary {
  final int id;
  final String slug;
  final String title;
  final String? accentColor;
  final CineClubeStatus status;
  final bool hasPassword;
  final bool isCycle;
  final CineClubeUser owner;
  final CineClubeMovie? movie;
  final DateTime startsOn;
  final DateTime endsOn;
  final DateTime? debateOn;
  final int totalSessions;
  final int totalParticipants;

  /// The current user takes part in it.
  final bool joined;

  const CineClubeSummary({
    required this.id,
    required this.slug,
    required this.title,
    this.accentColor,
    required this.status,
    this.hasPassword = false,
    this.isCycle = false,
    required this.owner,
    this.movie,
    required this.startsOn,
    required this.endsOn,
    this.debateOn,
    this.totalSessions = 1,
    this.totalParticipants = 0,
    this.joined = false,
  });
}

class CineClubePage {
  final List<CineClubeSummary> cineclubes;
  final int page;
  final bool hasNext;

  const CineClubePage({
    required this.cineclubes,
    this.page = 1,
    this.hasNext = false,
  });
}

/// Which CineClubes the list shows. By default, upcoming and running ones.
class CineClubeFilter {
  final String? query;

  /// Only the ones without a password.
  final bool open;
  final bool includeFinished;

  /// The ones the current user created.
  final bool mine;

  /// The ones a user joined (`me` for the current user).
  final String? participant;

  const CineClubeFilter({
    this.query,
    this.open = false,
    this.includeFinished = false,
    this.mine = false,
    this.participant,
  });

  CineClubeFilter copyWith({
    String? query,
    bool? open,
    bool? includeFinished,
    bool? mine,
    String? participant,
    bool clearParticipant = false,
  }) => CineClubeFilter(
    query: query ?? this.query,
    open: open ?? this.open,
    includeFinished: includeFinished ?? this.includeFinished,
    mine: mine ?? this.mine,
    participant: clearParticipant ? null : participant ?? this.participant,
  );
}

/// The current user's participation: their progress in the current session.
class CineClubeMembership {
  final DateTime joinedAt;
  final SessionProgress progress;
  final int completedSessions;

  const CineClubeMembership({
    required this.joinedAt,
    this.progress = SessionProgress.pending,
    this.completedSessions = 0,
  });
}

/// Where to watch the movie of the current session (TMDB watch providers).
class WatchProviderInfo {
  final String name;
  final String? logoPath;

  const WatchProviderInfo({required this.name, this.logoPath});
}

/// A CineClube with its sessions. [me] is the current user's participation
/// and [canEdit] is true for the owner.
class CineClube {
  final int id;
  final String slug;
  final String title;
  final String? description;
  final String? accentColor;
  final CineClubeStatus status;
  final bool hasPassword;
  final String? debateLink;
  final String? socialLink;
  final bool isCycle;
  final DateTime startsOn;
  final DateTime endsOn;
  final CineClubeUser owner;
  final List<CineClubeSession> sessions;
  final int? currentSessionId;
  final int totalParticipants;
  final List<WatchProviderInfo> watchProviders;
  final CineClubeMembership? me;
  final bool canEdit;

  const CineClube({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.accentColor,
    required this.status,
    this.hasPassword = false,
    this.debateLink,
    this.socialLink,
    this.isCycle = false,
    required this.startsOn,
    required this.endsOn,
    required this.owner,
    this.sessions = const [],
    this.currentSessionId,
    this.totalParticipants = 0,
    this.watchProviders = const [],
    this.me,
    this.canEdit = false,
  });

  bool get joined => me != null;

  CineClubeSession? get currentSession =>
      sessions.where((session) => session.id == currentSessionId).firstOrNull;
}

/// A participant of a session (F8.3).
class CineClubeParticipant {
  final CineClubeUser user;
  final SessionProgress progress;
  final int completedSessions;
  final DateTime? lastWatchedOn;
  final DateTime joinedAt;

  const CineClubeParticipant({
    required this.user,
    this.progress = SessionProgress.pending,
    this.completedSessions = 0,
    this.lastWatchedOn,
    required this.joinedAt,
  });
}

class ParticipantPage {
  final List<CineClubeParticipant> participants;
  final int page;
  final bool hasNext;

  const ParticipantPage({
    required this.participants,
    this.page = 1,
    this.hasNext = false,
  });
}

/// A watch log of a participant (F8.3). When [hidden], the server took the
/// comment and the GIF out: the user has not finished the movie and the
/// debate day has not come.
class CineClubeLog {
  final int id;
  final CineClubeUser user;
  final int sessionId;
  final DateTime watchedOn;
  final String mode;
  final int? minutesWatched;
  final int? percent;
  final bool completed;
  final List<Emotion> emotions;
  final String? gifUrl;
  final String? comment;
  final bool hasSpoiler;
  final bool hidden;
  final DateTime createdAt;

  const CineClubeLog({
    required this.id,
    required this.user,
    required this.sessionId,
    required this.watchedOn,
    this.mode = 'watched',
    this.minutesWatched,
    this.percent,
    this.completed = false,
    this.emotions = const [],
    this.gifUrl,
    this.comment,
    this.hasSpoiler = false,
    this.hidden = false,
    required this.createdAt,
  });
}

class CineClubeLogPage {
  final List<CineClubeLog> logs;
  final int page;
  final bool hasNext;

  const CineClubeLogPage({
    required this.logs,
    this.page = 1,
    this.hasNext = false,
  });
}

/// Answer of the slug check of the editor.
class CineClubeSlug {
  final String slug;
  final bool valid;
  final bool available;

  const CineClubeSlug({
    required this.slug,
    required this.valid,
    required this.available,
  });
}
