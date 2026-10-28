/// The fields a challenge's criteria can test (B7), each with its operator.
enum CriteriaField {
  /// TMDB genre ids.
  genre('genre', 'in'),

  /// `[from, to]`, inclusive.
  releaseYear('release_year', 'between'),

  /// First years of decades, like 1970.
  decade('decade', 'in'),

  /// ISO 3166-1 production countries.
  country('country', 'in'),

  /// ISO 639-1.
  originalLanguage('original_language', 'in'),

  /// TMDB person ids.
  director('director', 'in'),
  cast('cast', 'in'),

  /// Minutes.
  runtimeMin('runtime_min', 'gte'),
  runtimeMax('runtime_max', 'lte'),

  /// TMDB keyword ids.
  keyword('keyword', 'in'),

  /// TMDB score, 0 to 10.
  voteAverageMin('vote_average_min', 'gte');

  final String wireValue;
  final String op;

  const CriteriaField(this.wireValue, this.op);

  /// A single value (`gte`/`lte`) rather than a list.
  bool get isSingle => op == 'gte' || op == 'lte';

  static CriteriaField? fromWireValue(String? value) =>
      values.where((field) => field.wireValue == value).firstOrNull;
}

/// One condition of [ChallengeCriteria]. [values] holds ints for ids, years
/// and minutes, strings for countries and languages, and one number for the
/// single-value fields.
class CriteriaRule {
  final CriteriaField field;
  final List<Object> values;

  const CriteriaRule(this.field, this.values);

  List<int> get ints => values.whereType<num>().map((v) => v.toInt()).toList();

  List<String> get strings => values.whereType<String>().toList();
}

/// What a movie must have to complete a challenge by itself: every rule.
class ChallengeCriteria {
  final List<CriteriaRule> rules;

  const ChallengeCriteria(this.rules);

  bool get isEmpty => rules.isEmpty;

  CriteriaRule? rule(CriteriaField field) =>
      rules.where((rule) => rule.field == field).firstOrNull;
}
