import 'package:gamification_domain/models/models.dart';

/// JSON of the v1 gamification and games endpoints (backend README,
/// "Bichinho, missions and Caderninho" and "Watch parties and the poster
/// game") to domain models, and the diary day back to JSON.
abstract final class RemoteGamification {
  static PetShelter shelter(Map<String, dynamic> json) {
    final pinned = json['pinned'];
    return PetShelter(
      starterChosen: json['starterChosen'] as bool? ?? false,
      pets: _list(json['pets']).map(pet).toList(),
      pinned: pinned is Map<String, dynamic> ? pet(pinned) : null,
    );
  }

  static Pet pet(Map<String, dynamic> json) {
    final rule = _map(json['rule']);
    return Pet(
      slug: json['slug'] as String? ?? '',
      rarity: PetRarity.fromWireValue(json['rarity'] as String?),
      rule: PetRule(
        type: PetRuleType.fromWireValue(rule['type'] as String?),
        target: _int(rule['target']),
        genreId: rule['genreId'] as int?,
        beforeYear: rule['beforeYear'] as int?,
      ),
      unlocked: json['unlocked'] as bool? ?? false,
      progress: _int(json['progress']),
      xp: _int(json['xp']),
      level: _int(json['level']),
      levelXp: _int(json['levelXp']),
      nextLevelXp: _int(json['nextLevelXp']),
      starter: json['starter'] as bool? ?? false,
      pinned: json['pinned'] as bool? ?? false,
    );
  }

  static MissionWeek missions(Map<String, dynamic> json) => MissionWeek(
    weekStart: _date(json['weekStart']) ?? DateTime(0),
    weekEnd: _date(json['weekEnd']) ?? DateTime(0),
    missions: _list(json['missions'])
        .map(
          (mission) => Mission(
            slug: mission['slug'] as String? ?? '',
            type: mission['type'] as String? ?? 'sessions',
            target: _int(mission['target'], 1),
            progress: _int(mission['progress']),
            xp: _int(mission['xp']),
            completed: mission['completed'] as bool? ?? false,
          ),
        )
        .toList(),
  );

  static DiaryDay diaryDay(Map<String, dynamic> json) => DiaryDay(
    date: _date(json['date']) ?? DateTime(0),
    mood: DiaryMood.fromWireValue(json['mood'] as String?),
    note: json['note'] as String?,
    saved: json['saved'] as bool? ?? false,
    tasks: _list(json['tasks']).map((task) {
      final movie = task['movie'];
      return DiaryTask(
        category: DiaryCategory.fromWireValue(task['category'] as String?),
        description: task['description'] as String? ?? '',
        done: task['done'] as bool? ?? false,
        movie: movie is Map<String, dynamic>
            ? DiaryMovie(
                movieId: _int(movie['movieId']),
                title: movie['title'] as String? ?? '',
                posterPath: movie['posterPath'] as String?,
              )
            : null,
      );
    }).toList(),
  );

  static Map<String, dynamic> diaryBody(DiaryDay day) => {
    'mood': day.mood?.wireValue,
    'note': day.note,
    'tasks': [
      for (final task in day.tasks)
        {
          'category': task.category.wireValue,
          'description': task.description,
          'done': task.done,
          'movieId': ?task.movie?.movieId,
        },
    ],
  };

  static List<DiaryDaySummary> diaryMonth(List<dynamic> json) => json
      .whereType<Map<String, dynamic>>()
      .map(
        (day) => DiaryDaySummary(
          date: _date(day['date']) ?? DateTime(0),
          mood: DiaryMood.fromWireValue(day['mood'] as String?),
          tasks: _int(day['tasks']),
          done: _int(day['done']),
          hasNote: day['hasNote'] as bool? ?? false,
        ),
      )
      .toList();

  static DiaryYear diaryYear(Map<String, dynamic> json) {
    final months = List<Map<DiaryMood, int>>.generate(12, (_) => {});
    for (final month in _list(json['months'])) {
      final index = _int(month['month'], 1) - 1;
      if (index < 0 || index > 11) continue;
      final moods = _map(month['moods']);
      for (final entry in moods.entries) {
        final mood = DiaryMood.fromWireValue(entry.key);
        if (mood != null) months[index][mood] = _int(entry.value);
      }
    }
    return DiaryYear(
      year: _int(json['year']),
      days: _int(json['days']),
      months: months,
      topMood: DiaryMood.fromWireValue(json['topMood'] as String?),
    );
  }

  /// [received] is when the answer arrived, to measure the clock offset.
  static WatchParty party(Map<String, dynamic> json, DateTime received) {
    final serverTime = _instant(json['serverTime']);
    final movie = json['movie'];
    return WatchParty(
      code: json['code'] as String? ?? '',
      host: _user(_map(json['host'])),
      title: json['title'] as String? ?? '',
      movie: movie is Map<String, dynamic> ? gameMovie(movie) : null,
      startAt: _instant(json['startAt']),
      members: _list(json['members']).map(_user).toList(),
      messages: _list(json['messages'])
          .map(
            (message) => PartyMessage(
              id: _int(message['id']),
              user: _user(_map(message['user'])),
              body: message['body'] as String? ?? '',
              sentAt: _instant(message['sentAt']) ?? DateTime(0),
            ),
          )
          .toList(),
      isHost: json['self'] as bool? ?? false,
      clockOffset: serverTime == null
          ? Duration.zero
          : serverTime.difference(received),
    );
  }

  static PosterRound posterRound(Map<String, dynamic> json) => PosterRound(
    movie: gameMovie(_map(json['movie'])),
    options: _list(json['options']).map(gameMovie).toList(),
  );

  static GameMovie gameMovie(Map<String, dynamic> json) => GameMovie(
    movieId: _int(json['movieId']),
    title: json['title'] as String? ?? '',
    posterPath: json['posterPath'] as String?,
    year: json['year'] as int?,
  );

  static String day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static PartyUser _user(Map<String, dynamic> json) => PartyUser(
    id: json['id'] as String? ?? '',
    username: json['username'] as String? ?? '',
    displayName: json['displayName'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    accentColor: json['accentColor'] as String?,
  );

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const {};

  static int _int(Object? value, [int fallback = 0]) =>
      value is num ? value.toInt() : fallback;

  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? _instant(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}
