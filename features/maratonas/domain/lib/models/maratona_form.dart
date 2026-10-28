import 'package:maratonas_domain/models/criteria.dart';
import 'package:maratonas_domain/models/maratona.dart';

/// What the maratona editor sends (F7.7). Items with an id keep the stored
/// ones on edit. A null [password] keeps the current one.
class MaratonaForm {
  final String slug;
  final String title;
  final String? description;
  final String? logoUrl;
  final String? accentColor;
  final DateTime startsOn;
  final DateTime endsOn;
  final String? password;
  final bool removePassword;
  final String? socialLink;
  final List<CategoryForm> categories;
  final List<LevelForm> levels;
  final List<TeamForm> teams;
  final List<PrizeForm> prizes;

  const MaratonaForm({
    required this.slug,
    required this.title,
    this.description,
    this.logoUrl,
    this.accentColor,
    required this.startsOn,
    required this.endsOn,
    this.password,
    this.removePassword = false,
    this.socialLink,
    this.categories = const [],
    this.levels = const [],
    this.teams = const [],
    this.prizes = const [],
  });

  /// The form of a stored maratona, to edit it.
  factory MaratonaForm.of(Maratona maratona) => MaratonaForm(
    slug: maratona.slug,
    title: maratona.title,
    description: maratona.description,
    logoUrl: maratona.logoUrl,
    accentColor: maratona.accentColor,
    startsOn: maratona.startsOn,
    endsOn: maratona.endsOn,
    socialLink: maratona.socialLink,
    categories: [
      for (final category in maratona.categories)
        CategoryForm(
          id: category.id,
          name: category.name,
          teamOnly: category.teamOnly,
          challenges: [
            for (final challenge in category.challenges)
              ChallengeForm(
                id: challenge.id,
                description: challenge.description,
                criteria: challenge.criteria,
                daily: challenge.daily,
              ),
          ],
        ),
    ],
    levels: [
      for (final level in maratona.levels)
        LevelForm(
          id: level.id,
          name: level.name,
          minChallenges: level.minChallenges,
        ),
    ],
    teams: [
      for (final team in maratona.teams)
        TeamForm(id: team.id, name: team.name, color: team.color),
    ],
    prizes: [
      for (final prize in maratona.prizes)
        PrizeForm(title: prize.title, description: prize.description),
    ],
  );

  int get totalChallenges => categories.fold(
    0,
    (total, category) => total + category.challenges.length,
  );

  MaratonaForm copyWith({
    String? slug,
    String? title,
    String? description,
    String? logoUrl,
    String? accentColor,
    DateTime? startsOn,
    DateTime? endsOn,
    String? password,
    bool? removePassword,
    String? socialLink,
    List<CategoryForm>? categories,
    List<LevelForm>? levels,
    List<TeamForm>? teams,
    List<PrizeForm>? prizes,
  }) => MaratonaForm(
    slug: slug ?? this.slug,
    title: title ?? this.title,
    description: description ?? this.description,
    logoUrl: logoUrl ?? this.logoUrl,
    accentColor: accentColor ?? this.accentColor,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn ?? this.endsOn,
    password: password ?? this.password,
    removePassword: removePassword ?? this.removePassword,
    socialLink: socialLink ?? this.socialLink,
    categories: categories ?? this.categories,
    levels: levels ?? this.levels,
    teams: teams ?? this.teams,
    prizes: prizes ?? this.prizes,
  );
}

class CategoryForm {
  final int? id;
  final String name;
  final bool teamOnly;
  final List<ChallengeForm> challenges;

  const CategoryForm({
    this.id,
    required this.name,
    this.teamOnly = false,
    this.challenges = const [],
  });

  CategoryForm copyWith({
    String? name,
    bool? teamOnly,
    List<ChallengeForm>? challenges,
  }) => CategoryForm(
    id: id,
    name: name ?? this.name,
    teamOnly: teamOnly ?? this.teamOnly,
    challenges: challenges ?? this.challenges,
  );
}

/// A challenge; with [criteria] it completes by itself.
class ChallengeForm {
  final int? id;
  final String description;
  final ChallengeCriteria? criteria;
  final bool daily;

  const ChallengeForm({
    this.id,
    required this.description,
    this.criteria,
    this.daily = false,
  });
}

class LevelForm {
  final int? id;
  final String name;
  final int minChallenges;

  const LevelForm({this.id, required this.name, required this.minChallenges});
}

class TeamForm {
  final int? id;
  final String name;
  final String? color;

  const TeamForm({this.id, required this.name, this.color});
}

class PrizeForm {
  final String title;
  final String? description;

  const PrizeForm({required this.title, this.description});
}

/// A ready-made maratona (F7.9).
class MaratonaTemplate {
  final String id;
  final String title;
  final String description;

  /// Suggested length.
  final int days;
  final String accentColor;
  final List<CategoryForm> categories;

  const MaratonaTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.days,
    required this.accentColor,
    this.categories = const [],
  });

  int get totalChallenges => categories.fold(
    0,
    (total, category) => total + category.challenges.length,
  );
}
