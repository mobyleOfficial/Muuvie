import 'package:maratonas_domain/models/criteria.dart';

/// Where a maratona is in its period. Upcoming and active ones take joins.
enum MaratonaStatus {
  upcoming('upcoming'),
  active('active'),
  finished('finished'),
  cancelled('cancelled');

  final String wireValue;

  const MaratonaStatus(this.wireValue);

  bool get open => this == upcoming || this == active;

  static MaratonaStatus fromWireValue(String? value) =>
      values.where((status) => status.wireValue == value).firstOrNull ??
      upcoming;
}

/// Done by its criteria against the movie metadata, or only by hand.
enum ChallengeType {
  criteria('criteria'),
  free('free');

  final String wireValue;

  const ChallengeType(this.wireValue);

  static ChallengeType fromWireValue(String? value) =>
      values.where((type) => type.wireValue == value).firstOrNull ?? free;
}

/// Who tied a movie to a challenge: the user, or a logged session.
enum ChallengeLinkSource {
  manual('manual'),
  auto('auto');

  final String wireValue;

  const ChallengeLinkSource(this.wireValue);

  static ChallengeLinkSource fromWireValue(String? value) =>
      values.where((source) => source.wireValue == value).firstOrNull ?? manual;
}

/// A user as the maratonas show them (owner, co-owners, ranking).
class MaratonaUser {
  final String id;
  final String username;
  final String? handle;
  final String? displayName;
  final String? avatarUrl;
  final String? accentColor;

  const MaratonaUser({
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

/// A row of the maratona list (F7.2).
class MaratonaSummary {
  final int id;
  final String slug;
  final String title;
  final String? logoUrl;
  final String? accentColor;
  final DateTime startsOn;
  final DateTime endsOn;
  final MaratonaStatus status;
  final bool hasPassword;
  final bool trusted;
  final MaratonaUser owner;
  final int totalChallenges;
  final int totalParticipants;

  /// The current user takes part in it.
  final bool joined;

  const MaratonaSummary({
    required this.id,
    required this.slug,
    required this.title,
    this.logoUrl,
    this.accentColor,
    required this.startsOn,
    required this.endsOn,
    required this.status,
    this.hasPassword = false,
    this.trusted = false,
    required this.owner,
    this.totalChallenges = 0,
    this.totalParticipants = 0,
    this.joined = false,
  });
}

class MaratonaPage {
  final List<MaratonaSummary> maratonas;
  final int page;
  final bool hasNext;

  const MaratonaPage({
    required this.maratonas,
    this.page = 1,
    this.hasNext = false,
  });
}

/// Which maratonas the list shows. By default, upcoming and running ones.
class MaratonaFilter {
  final String? query;

  /// Only the ones without a password.
  final bool open;
  final bool includeFinished;

  /// Curated ones ("grupo confiável").
  final bool trusted;

  /// The ones the current user created or co-owns.
  final bool mine;

  /// The ones a user joined (`me` for the current user).
  final String? participant;

  const MaratonaFilter({
    this.query,
    this.open = false,
    this.includeFinished = false,
    this.trusted = false,
    this.mine = false,
    this.participant,
  });

  MaratonaFilter copyWith({
    String? query,
    bool? open,
    bool? includeFinished,
    bool? trusted,
    bool? mine,
    String? participant,
    bool clearParticipant = false,
  }) => MaratonaFilter(
    query: query ?? this.query,
    open: open ?? this.open,
    includeFinished: includeFinished ?? this.includeFinished,
    trusted: trusted ?? this.trusted,
    mine: mine ?? this.mine,
    participant: clearParticipant ? null : participant ?? this.participant,
  );
}

/// A maratona with its parts. [me] is the current user's participation and
/// [canEdit] is true for the owner and the co-owners.
class Maratona {
  final int id;
  final String slug;
  final String title;
  final String? description;
  final String? logoUrl;
  final String? accentColor;
  final DateTime startsOn;
  final DateTime endsOn;
  final MaratonaStatus status;
  final bool hasPassword;
  final String? socialLink;
  final bool trusted;
  final String? templateId;
  final MaratonaUser owner;
  final List<MaratonaUser> coOwners;
  final List<MaratonaCategory> categories;
  final List<MaratonaLevel> levels;
  final List<MaratonaTeam> teams;
  final List<MaratonaPrize> prizes;
  final int totalChallenges;
  final int totalParticipants;
  final MyParticipation? me;
  final bool canEdit;

  const Maratona({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.logoUrl,
    this.accentColor,
    required this.startsOn,
    required this.endsOn,
    required this.status,
    this.hasPassword = false,
    this.socialLink,
    this.trusted = false,
    this.templateId,
    required this.owner,
    this.coOwners = const [],
    this.categories = const [],
    this.levels = const [],
    this.teams = const [],
    this.prizes = const [],
    this.totalChallenges = 0,
    this.totalParticipants = 0,
    this.me,
    this.canEdit = false,
  });

  bool get joined => me != null;

  List<MaratonaChallenge> get challenges =>
      categories.expand((category) => category.challenges).toList();

  MaratonaLevel? level(int? id) =>
      levels.where((level) => level.id == id).firstOrNull ??
      (levels.isEmpty ? null : levels.first);

  MaratonaTeam? team(int? id) =>
      teams.where((team) => team.id == id).firstOrNull;
}

class MaratonaCategory {
  final int id;
  final String name;
  final bool teamOnly;
  final List<MaratonaChallenge> challenges;

  const MaratonaCategory({
    required this.id,
    required this.name,
    this.teamOnly = false,
    this.challenges = const [],
  });

  int get completed => challenges.where((c) => c.completed).length;
}

/// A challenge; [completed] and [links] are the current user's.
class MaratonaChallenge {
  final int id;
  final int categoryId;
  final String description;
  final ChallengeType type;
  final ChallengeCriteria? criteria;
  final bool daily;
  final bool completed;
  final List<ChallengeLink> links;

  const MaratonaChallenge({
    required this.id,
    required this.categoryId,
    required this.description,
    this.type = ChallengeType.free,
    this.criteria,
    this.daily = false,
    this.completed = false,
    this.links = const [],
  });
}

/// A movie tied to a challenge.
class ChallengeLink {
  final int challengeId;

  /// Database id: opens the movie detail.
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final ChallengeLinkSource source;
  final DateTime completedAt;

  const ChallengeLink({
    required this.challengeId,
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.source = ChallengeLinkSource.manual,
    required this.completedAt,
  });
}

/// [minChallenges] done challenges complete the maratona at this level.
class MaratonaLevel {
  final int id;
  final String name;
  final int minChallenges;

  const MaratonaLevel({
    required this.id,
    required this.name,
    required this.minChallenges,
  });
}

class MaratonaTeam {
  final int id;
  final String name;
  final String? color;

  const MaratonaTeam({required this.id, required this.name, this.color});
}

class MaratonaPrize {
  final int id;
  final String title;
  final String? description;

  const MaratonaPrize({
    required this.id,
    required this.title,
    this.description,
  });
}

class MyParticipation {
  final int? levelId;
  final int? teamId;

  /// The "Fila" shelf created on joining.
  final int? queueShelfId;
  final int completed;
  final DateTime joinedAt;

  const MyParticipation({
    this.levelId,
    this.teamId,
    this.queueShelfId,
    this.completed = 0,
    required this.joinedAt,
  });
}

/// Whether a maratona address can be used.
class SlugAvailability {
  final String slug;
  final bool valid;
  final bool available;

  const SlugAvailability({
    required this.slug,
    required this.valid,
    required this.available,
  });
}

/// A movie suggested for a challenge ("Descoberta", F7.3).
class SuggestedMovie {
  /// Database id: opens the movie detail.
  final int id;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? year;

  const SuggestedMovie({
    required this.id,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.year,
  });
}

class SuggestionPage {
  final List<SuggestedMovie> movies;
  final int page;
  final bool hasNext;

  const SuggestionPage({
    required this.movies,
    this.page = 1,
    this.hasNext = false,
  });
}
