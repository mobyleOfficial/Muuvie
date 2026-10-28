import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:movies/movies.dart';

/// What the criteria builder answered: the new criteria, or null to mark the
/// challenge by hand.
class CriteriaChoice {
  final ChallengeCriteria? criteria;

  const CriteriaChoice(this.criteria);
}

/// Builds the automatic criteria of a challenge (F7.7): genres, decades,
/// countries, original language, runtime and score. Rules it does not edit
/// (director, cast, keywords, exact years) are kept as they are.
class CriteriaSheet extends StatefulWidget {
  final ChallengeCriteria? criteria;

  const CriteriaSheet({super.key, this.criteria});

  static Future<CriteriaChoice?> show(
    BuildContext context,
    ChallengeCriteria? criteria,
  ) => MuuvieBottomSheet.show<CriteriaChoice>(
    context: context,
    builder: (_) => CriteriaSheet(criteria: criteria),
  );

  @override
  State<CriteriaSheet> createState() => _CriteriaSheetState();
}

class _CriteriaSheetState extends State<CriteriaSheet> {
  static const _decades = [
    1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020, //
  ];
  static const _edited = {
    CriteriaField.genre,
    CriteriaField.decade,
    CriteriaField.country,
    CriteriaField.originalLanguage,
    CriteriaField.runtimeMin,
    CriteriaField.runtimeMax,
    CriteriaField.voteAverageMin,
  };

  List<Genre> _genres = const [];
  late final Set<int> _genreIds = {...?_first(CriteriaField.genre)?.ints};
  late final Set<int> _decadeIds = {...?_first(CriteriaField.decade)?.ints};
  late final _countries = TextEditingController(
    text: _first(CriteriaField.country)?.strings.join(', ') ?? '',
  );
  late final _languages = TextEditingController(
    text: _first(CriteriaField.originalLanguage)?.strings.join(', ') ?? '',
  );
  late final _runtimeMin = TextEditingController(
    text: _single(CriteriaField.runtimeMin),
  );
  late final _runtimeMax = TextEditingController(
    text: _single(CriteriaField.runtimeMax),
  );
  late final _vote = TextEditingController(
    text: _single(CriteriaField.voteAverageMin),
  );

  /// Rules the builder leaves alone: other fields, and repeated ones.
  late final List<CriteriaRule> _kept = () {
    final seen = <CriteriaField>{};
    return [
      for (final rule in widget.criteria?.rules ?? const <CriteriaRule>[])
        if (!_edited.contains(rule.field) || !seen.add(rule.field)) rule,
    ];
  }();

  CriteriaRule? _first(CriteriaField field) => widget.criteria?.rule(field);

  String _single(CriteriaField field) {
    final value = _first(field)?.values.firstOrNull;
    return value is num ? (value % 1 == 0 ? '${value.toInt()}' : '$value') : '';
  }

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final result = await GetIt.I<GetGenres>()();
    if (!mounted) return;
    if (result case Success(:final data)) setState(() => _genres = data);
  }

  @override
  void dispose() {
    _countries.dispose();
    _languages.dispose();
    _runtimeMin.dispose();
    _runtimeMax.dispose();
    _vote.dispose();
    super.dispose();
  }

  static List<String> _codes(String text, int length) => text
      .split(RegExp(r'[,\s]+'))
      .map((code) => code.trim())
      .where((code) => code.length >= 2 && code.length <= length)
      .toSet()
      .toList();

  ChallengeCriteria? _build() {
    final runtimeMin = int.tryParse(_runtimeMin.text.trim());
    final runtimeMax = int.tryParse(_runtimeMax.text.trim());
    final vote = double.tryParse(_vote.text.trim().replaceAll(',', '.'));
    final countries = _codes(_countries.text, 2).map((c) => c.toUpperCase());
    final languages = _codes(_languages.text, 3).map((c) => c.toLowerCase());
    final rules = [
      if (_genreIds.isNotEmpty)
        CriteriaRule(CriteriaField.genre, _genreIds.toList()),
      if (_decadeIds.isNotEmpty)
        CriteriaRule(CriteriaField.decade, (_decadeIds.toList()..sort())),
      if (countries.isNotEmpty)
        CriteriaRule(CriteriaField.country, countries.toList()),
      if (languages.isNotEmpty)
        CriteriaRule(CriteriaField.originalLanguage, languages.toList()),
      if (runtimeMin != null && runtimeMin > 0)
        CriteriaRule(CriteriaField.runtimeMin, [runtimeMin]),
      if (runtimeMax != null && runtimeMax > 0)
        CriteriaRule(CriteriaField.runtimeMax, [runtimeMax]),
      if (vote != null && vote >= 0 && vote <= 10)
        CriteriaRule(CriteriaField.voteAverageMin, [vote]),
      ..._kept,
    ];
    return rules.isEmpty ? null : ChallengeCriteria(rules);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.85,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l10n?.maratonaCriteria ?? '',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.maratonaCriteriaGenres ?? '',
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      if (_genres.isEmpty)
                        const MuuvieActivityIndicator()
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final genre in _genres)
                              FilterChip(
                                label: Text(genre.name),
                                selected: _genreIds.contains(genre.id),
                                onSelected: (selected) => setState(
                                  () => selected
                                      ? _genreIds.add(genre.id)
                                      : _genreIds.remove(genre.id),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Text(
                        l10n?.maratonaCriteriaDecades ?? '',
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final decade in _decades)
                            FilterChip(
                              label: Text('$decade'),
                              selected: _decadeIds.contains(decade),
                              onSelected: (selected) => setState(
                                () => selected
                                    ? _decadeIds.add(decade)
                                    : _decadeIds.remove(decade),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _countries,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: l10n?.maratonaCriteriaCountries,
                          helperText: l10n?.maratonaCriteriaCodesHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _languages,
                        decoration: InputDecoration(
                          labelText: l10n?.maratonaCriteriaLanguages,
                          helperText: l10n?.maratonaCriteriaCodesHint,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _runtimeMin,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n?.maratonaCriteriaRuntimeMin,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _runtimeMax,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n?.maratonaCriteriaRuntimeMax,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _vote,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n?.maratonaCriteriaVote,
                        ),
                      ),
                      if (_kept.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n?.maratonaCriteriaKept ?? '',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(const CriteriaChoice(null)),
                        child: Text(l10n?.maratonaCriteriaClear ?? ''),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () =>
                            Navigator.of(context).pop(CriteriaChoice(_build())),
                        child: Text(l10n?.maratonaCriteriaApply ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
