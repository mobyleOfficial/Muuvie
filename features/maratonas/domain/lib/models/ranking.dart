import 'package:maratonas_domain/models/maratona.dart';

/// A participant in the ranking (F7.6). A tie shares the [position].
class RankingEntry {
  final int position;
  final MaratonaUser user;
  final int? teamId;
  final int completed;
  final DateTime? lastCompletedAt;

  const RankingEntry({
    required this.position,
    required this.user,
    this.teamId,
    this.completed = 0,
    this.lastCompletedAt,
  });
}

class RankingPage {
  final List<RankingEntry> entries;
  final int page;
  final bool hasNext;

  const RankingPage({
    required this.entries,
    this.page = 1,
    this.hasNext = false,
  });
}

class TeamRankingEntry {
  final int position;
  final MaratonaTeam team;
  final int members;
  final int completed;

  const TeamRankingEntry({
    required this.position,
    required this.team,
    this.members = 0,
    this.completed = 0,
  });
}
