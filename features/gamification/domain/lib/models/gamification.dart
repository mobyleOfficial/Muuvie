// ── Bichinho (F10.1) ────────────────────────────────────────────────────────

enum PetRarity {
  starter('starter'),
  common('common'),
  rare('rare'),
  legendary('legendary');

  final String wireValue;

  const PetRarity(this.wireValue);

  static PetRarity fromWireValue(String? value) =>
      values.where((r) => r.wireValue == value).firstOrNull ?? common;
}

/// What unlocks a bichinho; [target] is how many of it.
enum PetRuleType {
  starter('starter'),
  movies('movies'),
  minutes('minutes'),
  genreMovies('genre_movies'),
  oldMovies('old_movies'),
  maratonasFinished('maratonas_finished'),
  cineclubesJoined('cineclubes_joined'),
  missions('missions');

  final String wireValue;

  const PetRuleType(this.wireValue);

  static PetRuleType fromWireValue(String? value) =>
      values.where((t) => t.wireValue == value).firstOrNull ?? movies;
}

class PetRule {
  final PetRuleType type;
  final int target;
  final int? genreId;
  final int? beforeYear;

  const PetRule({
    required this.type,
    this.target = 0,
    this.genreId,
    this.beforeYear,
  });
}

/// A bichinho of the shelter. Locked ones carry their [progress]; unlocked
/// ones their XP and level. The app draws and names it by [slug].
class Pet {
  final String slug;
  final PetRarity rarity;
  final PetRule rule;
  final bool unlocked;
  final int progress;
  final int xp;
  final int level;
  final int levelXp;
  final int nextLevelXp;
  final bool starter;
  final bool pinned;

  const Pet({
    required this.slug,
    this.rarity = PetRarity.common,
    this.rule = const PetRule(type: PetRuleType.movies),
    this.unlocked = false,
    this.progress = 0,
    this.xp = 0,
    this.level = 0,
    this.levelXp = 0,
    this.nextLevelXp = 0,
    this.starter = false,
    this.pinned = false,
  });

  /// How far the bichinho is in its level, 0 to 1.
  double get levelProgress {
    final span = nextLevelXp - levelXp;
    return span <= 0 ? 1 : ((xp - levelXp) / span).clamp(0, 1).toDouble();
  }

  /// How far a locked bichinho is from its rule, 0 to 1.
  double get unlockProgress =>
      rule.target <= 0 ? 0 : (progress / rule.target).clamp(0, 1).toDouble();
}

class PetShelter {
  final bool starterChosen;
  final List<Pet> pets;
  final Pet? pinned;

  const PetShelter({
    this.starterChosen = false,
    this.pets = const [],
    this.pinned,
  });
}

// ── Missions (F10.2) ────────────────────────────────────────────────────────

class Mission {
  final String slug;
  final String type;
  final int target;
  final int progress;
  final int xp;
  final bool completed;

  const Mission({
    required this.slug,
    this.type = 'sessions',
    this.target = 1,
    this.progress = 0,
    this.xp = 0,
    this.completed = false,
  });

  double get fraction =>
      target <= 0 ? 0 : (progress / target).clamp(0, 1).toDouble();
}

class MissionWeek {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<Mission> missions;

  const MissionWeek({
    required this.weekStart,
    required this.weekEnd,
    this.missions = const [],
  });
}

// ── Caderninho (F10.3) ──────────────────────────────────────────────────────

enum DiaryMood {
  great('great'),
  good('good'),
  okay('okay'),
  bad('bad'),
  awful('awful');

  final String wireValue;

  const DiaryMood(this.wireValue);

  static DiaryMood? fromWireValue(String? value) =>
      values.where((m) => m.wireValue == value).firstOrNull;
}

enum DiaryCategory {
  movie('movie'),
  short('short'),
  series('series'),
  study('study'),
  other('other');

  final String wireValue;

  const DiaryCategory(this.wireValue);

  static DiaryCategory fromWireValue(String? value) =>
      values.where((c) => c.wireValue == value).firstOrNull ?? other;
}

class DiaryMovie {
  final int movieId;
  final String title;
  final String? posterPath;

  const DiaryMovie({
    required this.movieId,
    required this.title,
    this.posterPath,
  });
}

class DiaryTask {
  final DiaryCategory category;
  final String description;
  final bool done;
  final DiaryMovie? movie;

  const DiaryTask({
    this.category = DiaryCategory.other,
    required this.description,
    this.done = false,
    this.movie,
  });

  DiaryTask copyWith({
    DiaryCategory? category,
    String? description,
    bool? done,
  }) => DiaryTask(
    category: category ?? this.category,
    description: description ?? this.description,
    done: done ?? this.done,
    movie: movie,
  );
}

/// A day of the Caderninho. [saved] is false for a day never written.
class DiaryDay {
  final DateTime date;
  final DiaryMood? mood;
  final String? note;
  final List<DiaryTask> tasks;
  final bool saved;

  const DiaryDay({
    required this.date,
    this.mood,
    this.note,
    this.tasks = const [],
    this.saved = false,
  });

  static const maxTasks = 6;
}

class DiaryDaySummary {
  final DateTime date;
  final DiaryMood? mood;
  final int tasks;
  final int done;
  final bool hasNote;

  const DiaryDaySummary({
    required this.date,
    this.mood,
    this.tasks = 0,
    this.done = 0,
    this.hasNote = false,
  });
}

class DiaryYear {
  final int year;
  final int days;

  /// Mood counts per month (index 0 is January).
  final List<Map<DiaryMood, int>> months;
  final DiaryMood? topMood;

  const DiaryYear({
    required this.year,
    this.days = 0,
    this.months = const [],
    this.topMood,
  });
}

// ── Watch party (F10.4) and poster game (F10.5) ─────────────────────────────

class PartyUser {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? accentColor;

  const PartyUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.accentColor,
  });

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;
}

class PartyMessage {
  final int id;
  final PartyUser user;
  final String body;
  final DateTime sentAt;

  const PartyMessage({
    required this.id,
    required this.user,
    required this.body,
    required this.sentAt,
  });
}

class GameMovie {
  final int movieId;
  final String title;
  final String? posterPath;
  final int? year;

  const GameMovie({
    required this.movieId,
    required this.title,
    this.posterPath,
    this.year,
  });
}

/// A watch party room. [clockOffset] is the server clock minus the device
/// clock when the room was read, so the countdown is the same for everyone.
class WatchParty {
  final String code;
  final PartyUser host;
  final String title;
  final GameMovie? movie;
  final DateTime? startAt;
  final List<PartyUser> members;
  final List<PartyMessage> messages;
  final bool isHost;
  final Duration clockOffset;

  const WatchParty({
    required this.code,
    required this.host,
    required this.title,
    this.movie,
    this.startAt,
    this.members = const [],
    this.messages = const [],
    this.isHost = false,
    this.clockOffset = Duration.zero,
  });

  /// How long until play, as seen on this device; null before the countdown.
  Duration? remaining(DateTime deviceNow) {
    final start = startAt;
    if (start == null) return null;
    return start.difference(deviceNow.add(clockOffset));
  }
}

/// A change in a party, from the WebSocket.
class PartyEvent {
  final String code;
  final String event;

  const PartyEvent({required this.code, required this.event});
}

class PosterRound {
  final GameMovie movie;
  final List<GameMovie> options;

  const PosterRound({required this.movie, required this.options});
}
