import 'package:cineclubes_domain/models/models.dart';
import 'package:core/core.dart';

/// JSON of the v1 CineClube endpoints (backend README, "CineClubes") to
/// domain models, and the editor form back to JSON.
abstract final class RemoteCineClubes {
  static CineClubePage page(Map<String, dynamic> json) => CineClubePage(
    cineclubes: _list(json['results']).map(summary).toList(),
    page: _int(json['page'], 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static CineClubeSummary summary(Map<String, dynamic> json) {
    final movie = json['movie'];
    return CineClubeSummary(
      id: _int(json['id']),
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      accentColor: json['accentColor'] as String?,
      status: CineClubeStatus.fromWireValue(json['status'] as String?),
      hasPassword: json['hasPassword'] as bool? ?? false,
      isCycle: json['isCycle'] as bool? ?? false,
      owner: user(_map(json['owner'])),
      movie: movie is Map<String, dynamic>
          ? RemoteCineClubes.movie(movie)
          : null,
      startsOn: _date(json['startsOn']) ?? DateTime(0),
      endsOn: _date(json['endsOn']) ?? DateTime(0),
      debateOn: _date(json['debateOn']),
      totalSessions: _int(json['totalSessions'], 1),
      totalParticipants: _int(json['totalParticipants']),
      joined: json['joined'] as bool? ?? false,
    );
  }

  static CineClube cineclube(Map<String, dynamic> json) {
    final me = json['me'];
    return CineClube(
      id: _int(json['id']),
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      accentColor: json['accentColor'] as String?,
      status: CineClubeStatus.fromWireValue(json['status'] as String?),
      hasPassword: json['hasPassword'] as bool? ?? false,
      debateLink: json['debateLink'] as String?,
      socialLink: json['socialLink'] as String?,
      isCycle: json['isCycle'] as bool? ?? false,
      startsOn: _date(json['startsOn']) ?? DateTime(0),
      endsOn: _date(json['endsOn']) ?? DateTime(0),
      owner: user(_map(json['owner'])),
      sessions: _list(json['sessions']).map(session).toList(),
      currentSessionId: json['currentSessionId'] as int?,
      totalParticipants: _int(json['totalParticipants']),
      watchProviders: _list(json['watchProviders'])
          .map(
            (provider) => WatchProviderInfo(
              name: provider['name'] as String? ?? '',
              logoPath: provider['logoPath'] as String?,
            ),
          )
          .where((provider) => provider.name.isNotEmpty)
          .toList(),
      me: me is Map<String, dynamic>
          ? CineClubeMembership(
              joinedAt: _date(me['joinedAt']) ?? DateTime(0),
              progress: SessionProgress.fromWireValue(
                me['progress'] as String?,
              ),
              completedSessions: _int(me['completedSessions']),
            )
          : null,
      canEdit: json['canEdit'] as bool? ?? false,
    );
  }

  static CineClubeSession session(Map<String, dynamic> json) {
    final startsOn = _date(json['startsOn']) ?? DateTime(0);
    final endsOn = _date(json['endsOn']) ?? startsOn;
    return CineClubeSession(
      id: _int(json['id']),
      position: _int(json['position']),
      movie: movie(_map(json['movie'])),
      startsOn: startsOn,
      endsOn: endsOn,
      debateOn: _date(json['debateOn']) ?? endsOn,
    );
  }

  static CineClubeMovie movie(Map<String, dynamic> json) => CineClubeMovie(
    id: _int(json['id']),
    tmdbId: json['tmdbId'] as int?,
    title: json['title'] as String? ?? '',
    posterPath: json['posterPath'] as String?,
    year: json['year'] as int?,
    runtime: json['runtime'] as int?,
  );

  static CineClubeUser user(Map<String, dynamic> json) => CineClubeUser(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? '',
    handle: json['handle'] as String?,
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    accentColor: json['accentColor'] as String?,
  );

  static CineClubeLogPage logs(Map<String, dynamic> json) => CineClubeLogPage(
    logs: _list(json['results'])
        .map(
          (log) => CineClubeLog(
            id: _int(log['id']),
            user: user(_map(log['user'])),
            sessionId: _int(log['sessionId']),
            watchedOn: _date(log['watchedOn']) ?? DateTime(0),
            mode: log['mode'] as String? ?? 'watched',
            minutesWatched: log['minutesWatched'] as int?,
            percent: log['percent'] as int?,
            completed: log['completed'] as bool? ?? false,
            emotions: (log['emotions'] as List? ?? const [])
                .map((value) => Emotion.fromWireValue(value as String?))
                .whereType<Emotion>()
                .toList(),
            gifUrl: log['gifUrl'] as String?,
            comment: log['comment'] as String?,
            hasSpoiler: log['hasSpoiler'] as bool? ?? false,
            hidden: log['hidden'] as bool? ?? false,
            createdAt: _instant(log['createdAt']) ?? DateTime(0),
          ),
        )
        .toList(),
    page: _int(json['page'], 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static ParticipantPage participants(Map<String, dynamic> json) =>
      ParticipantPage(
        participants: _list(json['results'])
            .map(
              (participant) => CineClubeParticipant(
                user: user(_map(participant['user'])),
                progress: SessionProgress.fromWireValue(
                  participant['progress'] as String?,
                ),
                completedSessions: _int(participant['completedSessions']),
                lastWatchedOn: _date(participant['lastWatchedOn']),
                joinedAt: _instant(participant['joinedAt']) ?? DateTime(0),
              ),
            )
            .toList(),
        page: _int(json['page'], 1),
        hasNext: json['hasNext'] as bool? ?? false,
      );

  static CineClubeSlug slug(Map<String, dynamic> json) => CineClubeSlug(
    slug: json['slug'] as String? ?? '',
    valid: json['valid'] as bool? ?? false,
    available: json['available'] as bool? ?? false,
  );

  // ── Form to JSON ──────────────────────────────────────────────────────

  static Map<String, dynamic> form(CineClubeForm form) => {
    'slug': form.slug,
    'title': form.title,
    'description': form.description,
    'accentColor': form.accentColor,
    'password': ?form.password,
    'removePassword': form.removePassword,
    'debateLink': form.debateLink,
    'socialLink': form.socialLink,
    'sessions': [
      for (final session in form.sessions)
        {
          'id': ?session.id,
          if (session.movie.id > 0)
            'movieId': session.movie.id
          else ...{
            'tmdbId': session.movie.tmdbId,
            'title': session.movie.title,
          },
          'startsOn': day(session.startsOn),
          'endsOn': day(session.endsOn),
          'debateOn': day(session.debateOn),
        },
    ],
  };

  static String day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  // ── Helpers ───────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static int _int(Object? value, [int fallback = 0]) =>
      value is num ? value.toInt() : fallback;

  /// A calendar day ("2026-10-05"), kept as that day in any time zone.
  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? _instant(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
