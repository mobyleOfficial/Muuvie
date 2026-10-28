import 'package:maratonas_domain/models/models.dart';

/// JSON of the v1 maratona endpoints (backend README, "Maratonas") to domain
/// models, and the editor form back to JSON.
abstract final class RemoteMaratonas {
  static MaratonaPage page(Map<String, dynamic> json) => MaratonaPage(
    maratonas: _list(json['results']).map(summary).toList(),
    page: _int(json['page'], 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static MaratonaSummary summary(Map<String, dynamic> json) => MaratonaSummary(
    id: _int(json['id']),
    slug: json['slug'] as String? ?? '',
    title: json['title'] as String? ?? '',
    logoUrl: json['logoUrl'] as String?,
    accentColor: json['accentColor'] as String?,
    startsOn: _date(json['startsOn']) ?? DateTime(0),
    endsOn: _date(json['endsOn']) ?? DateTime(0),
    status: MaratonaStatus.fromWireValue(json['status'] as String?),
    hasPassword: json['hasPassword'] as bool? ?? false,
    trusted: json['trusted'] as bool? ?? false,
    owner: user(_map(json['owner'])),
    totalChallenges: _int(json['totalChallenges']),
    totalParticipants: _int(json['totalParticipants']),
    joined: json['joined'] as bool? ?? false,
  );

  static Maratona maratona(Map<String, dynamic> json) {
    final me = json['me'];
    return Maratona(
      id: _int(json['id']),
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      accentColor: json['accentColor'] as String?,
      startsOn: _date(json['startsOn']) ?? DateTime(0),
      endsOn: _date(json['endsOn']) ?? DateTime(0),
      status: MaratonaStatus.fromWireValue(json['status'] as String?),
      hasPassword: json['hasPassword'] as bool? ?? false,
      socialLink: json['socialLink'] as String?,
      trusted: json['trusted'] as bool? ?? false,
      templateId: json['templateId'] as String?,
      owner: user(_map(json['owner'])),
      coOwners: _list(json['coOwners']).map(user).toList(),
      categories: categories(json['categories']),
      levels: _list(json['levels'])
          .map(
            (level) => MaratonaLevel(
              id: _int(level['id']),
              name: level['name'] as String? ?? '',
              minChallenges: _int(level['minChallenges'], 1),
            ),
          )
          .toList(),
      teams: _list(json['teams']).map(team).toList(),
      prizes: _list(json['prizes'])
          .map(
            (prize) => MaratonaPrize(
              id: _int(prize['id']),
              title: prize['title'] as String? ?? '',
              description: prize['description'] as String?,
            ),
          )
          .toList(),
      totalChallenges: _int(json['totalChallenges']),
      totalParticipants: _int(json['totalParticipants']),
      me: me is Map<String, dynamic>
          ? MyParticipation(
              levelId: me['levelId'] as int?,
              teamId: me['teamId'] as int?,
              queueShelfId: me['queueShelfId'] as int?,
              completed: _int(me['completed']),
              joinedAt: _date(me['joinedAt']) ?? DateTime(0),
            )
          : null,
      canEdit: json['canEdit'] as bool? ?? false,
    );
  }

  static List<MaratonaCategory> categories(Object? json) => _list(json)
      .map(
        (category) => MaratonaCategory(
          id: _int(category['id']),
          name: category['name'] as String? ?? '',
          teamOnly: category['teamOnly'] as bool? ?? false,
          challenges: _list(category['challenges']).map(challenge).toList(),
        ),
      )
      .toList();

  static MaratonaChallenge challenge(Map<String, dynamic> json) =>
      MaratonaChallenge(
        id: _int(json['id']),
        categoryId: _int(json['categoryId']),
        description: json['description'] as String? ?? '',
        type: ChallengeType.fromWireValue(json['type'] as String?),
        criteria: criteria(json['criteria']),
        daily: json['daily'] as bool? ?? false,
        completed: json['completed'] as bool? ?? false,
        links: _list(json['links'])
            .map(
              (link) => ChallengeLink(
                challengeId: _int(link['challengeId']),
                movieId: _int(link['movieId']),
                tmdbId: link['tmdbId'] as int?,
                title: link['title'] as String? ?? '',
                posterPath: link['posterPath'] as String?,
                source: ChallengeLinkSource.fromWireValue(
                  link['source'] as String?,
                ),
                completedAt: _date(link['completedAt']) ?? DateTime(0),
              ),
            )
            .toList(),
      );

  /// Null when there are no criteria; rules with a field this version of the
  /// app does not know are left out.
  static ChallengeCriteria? criteria(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final rules = <CriteriaRule>[];
    for (final rule in _list(json['all'])) {
      final field = CriteriaField.fromWireValue(rule['field'] as String?);
      if (field == null) continue;
      final value = rule['value'];
      final values = <Object>[
        if (value is List)
          ...value.whereType<Object>()
        else
          ?(value as Object?),
      ];
      rules.add(CriteriaRule(field, values));
    }
    return rules.isEmpty ? null : ChallengeCriteria(rules);
  }

  static MaratonaUser user(Map<String, dynamic> json) => MaratonaUser(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? '',
    handle: json['handle'] as String?,
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    accentColor: json['accentColor'] as String?,
  );

  static MaratonaTeam team(Map<String, dynamic> json) => MaratonaTeam(
    id: _int(json['id']),
    name: json['name'] as String? ?? '',
    color: json['color'] as String?,
  );

  static SlugAvailability slug(Map<String, dynamic> json) => SlugAvailability(
    slug: json['slug'] as String? ?? '',
    valid: json['valid'] as bool? ?? false,
    available: json['available'] as bool? ?? false,
  );

  static SuggestionPage suggestions(Map<String, dynamic> json) =>
      SuggestionPage(
        movies: _list(json['results'])
            .map(
              (movie) => SuggestedMovie(
                id: _int(movie['id']),
                tmdbId: movie['tmdbId'] as int?,
                title: movie['title'] as String? ?? '',
                posterPath: movie['posterPath'] as String?,
                year: _year(movie),
              ),
            )
            .toList(),
        page: _int(json['page'], 1),
        hasNext: json['hasNext'] as bool? ?? false,
      );

  static RankingPage ranking(Map<String, dynamic> json) => RankingPage(
    entries: _list(json['results'])
        .map(
          (entry) => RankingEntry(
            position: _int(entry['position'], 1),
            user: user(_map(entry['user'])),
            teamId: entry['teamId'] as int?,
            completed: _int(entry['completed']),
            lastCompletedAt: _date(entry['lastCompletedAt']),
          ),
        )
        .toList(),
    page: _int(json['page'], 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static List<TeamRankingEntry> teamRanking(Map<String, dynamic> json) =>
      _list(json['results'])
          .map(
            (entry) => TeamRankingEntry(
              position: _int(entry['position'], 1),
              team: team(_map(entry['team'])),
              members: _int(entry['members']),
              completed: _int(entry['completed']),
            ),
          )
          .toList();

  static List<MaratonaTemplate> templates(Object? json) => _list(json)
      .map(
        (template) => MaratonaTemplate(
          id: template['id'] as String? ?? '',
          title: template['title'] as String? ?? '',
          description: template['description'] as String? ?? '',
          days: _int(template['days'], 30),
          accentColor: template['accentColor'] as String? ?? '',
          categories: _list(template['categories'])
              .map(
                (category) => CategoryForm(
                  name: category['name'] as String? ?? '',
                  teamOnly: category['teamOnly'] as bool? ?? false,
                  challenges: _list(category['challenges'])
                      .map(
                        (challenge) => ChallengeForm(
                          description:
                              challenge['description'] as String? ?? '',
                          criteria: criteria(challenge['criteria']),
                          daily: challenge['daily'] as bool? ?? false,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      )
      .toList();

  // ── Form to JSON ──────────────────────────────────────────────────────

  static Map<String, dynamic> form(MaratonaForm form) => {
    'slug': form.slug,
    'title': form.title,
    'description': form.description,
    'logoUrl': form.logoUrl,
    'accentColor': form.accentColor,
    'startsOn': _day(form.startsOn),
    'endsOn': _day(form.endsOn),
    'password': ?form.password,
    'removePassword': form.removePassword,
    'socialLink': form.socialLink,
    'categories': [
      for (final category in form.categories)
        {
          'id': ?category.id,
          'name': category.name,
          'teamOnly': category.teamOnly,
          'challenges': [
            for (final challenge in category.challenges)
              {
                'id': ?challenge.id,
                'description': challenge.description,
                'criteria': ?criteriaJson(challenge.criteria),
                'daily': challenge.daily,
              },
          ],
        },
    ],
    'levels': [
      for (final level in form.levels)
        {
          'id': ?level.id,
          'name': level.name,
          'minChallenges': level.minChallenges,
        },
    ],
    'teams': [
      for (final team in form.teams)
        {'id': ?team.id, 'name': team.name, 'color': team.color},
    ],
    'prizes': [
      for (final prize in form.prizes)
        {'title': prize.title, 'description': prize.description},
    ],
  };

  static Map<String, dynamic>? criteriaJson(ChallengeCriteria? criteria) {
    if (criteria == null || criteria.isEmpty) return null;
    return {
      'all': [
        for (final rule in criteria.rules)
          {
            'field': rule.field.wireValue,
            'op': rule.field.op,
            'value': rule.field.isSingle ? rule.values.first : rule.values,
          },
      ],
    };
  }

  static String day(DateTime date) => _day(date);

  // ── Helpers ───────────────────────────────────────────────────────────

  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static int? _year(Map<String, dynamic> movie) {
    final year = movie['year'];
    if (year is int) return year;
    final date = movie['releaseDate'] as String?;
    return date == null || date.length < 4
        ? null
        : int.tryParse(date.substring(0, 4));
  }

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static int _int(Object? value, [int fallback = 0]) =>
      value is num ? value.toInt() : fallback;

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
