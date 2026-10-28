import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:profile_ui/tabs/charts/chart_widgets.dart';
import 'package:profile_ui/tabs/charts/charts_bloc.dart';
import 'package:profile_ui/tabs/charts/charts_state.dart';
import 'package:stats/stats.dart';

/// The Gráficos tab (F9.2): year picker, goal, totals ("horas na frente da
/// tela"), months, genres, decades, countries, languages, where, directors,
/// emotions, stars and the calendar heatmap.
class ChartsScreen extends StatelessWidget {
  static const _top = 8;

  final ChartsCubit cubit;
  final bool isSelf;
  final ValueChanged<YearlyGoal?>? onEditGoal;
  final VoidCallback? onRemoveGoal;
  final ValueChanged<int>? onOpenRetrospective;

  const ChartsScreen({
    super.key,
    required this.cubit,
    this.isSelf = false,
    this.onEditGoal,
    this.onRemoveGoal,
    this.onOpenRetrospective,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ChartsCubit, ChartsState>(
        builder: (context, state) => switch (state) {
          ChartsLoading() => const Center(child: MuuvieActivityIndicator()),
          ChartsError() => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          final ChartsSuccess success => _Charts(
            state: success,
            isSelf: isSelf,
            currentYear: cubit.currentYear,
            onSelectYear: cubit.selectYear,
            onEditGoal: onEditGoal,
            onRemoveGoal: onRemoveGoal,
            onOpenRetrospective: onOpenRetrospective,
          ),
        },
      ),
    );
  }
}

class _Charts extends StatelessWidget {
  final ChartsSuccess state;
  final bool isSelf;
  final int currentYear;
  final ValueChanged<int> onSelectYear;
  final ValueChanged<YearlyGoal?>? onEditGoal;
  final VoidCallback? onRemoveGoal;
  final ValueChanged<int>? onOpenRetrospective;

  const _Charts({
    required this.state,
    required this.isSelf,
    required this.currentYear,
    required this.onSelectYear,
    required this.onEditGoal,
    required this.onRemoveGoal,
    required this.onOpenRetrospective,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    final stats = state.stats;
    final locale = Intl.getCurrentLocale();
    final monthFormat = DateFormat('MMMMM', locale);
    final monthLabels = [
      for (var m = 1; m <= 12; m++) monthFormat.format(DateTime(2000, m)),
    ];
    final canSetGoal =
        isSelf && (state.year == currentYear || state.year == currentYear + 1);
    final palette = [
      color,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.error,
      // primaryContainer is as dark as primary in this theme; teal stays apart.
      Colors.teal.shade400,
      colorScheme.outline,
    ];
    final retrospective = onOpenRetrospective;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (final year in state.years)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$year'),
                    selected: year == state.year,
                    onSelected: (_) => onSelectYear(year),
                  ),
                ),
            ],
          ),
        ),
        if (state.loadingYear) const LinearProgressIndicator(),
        if (state.goal != null || canSetGoal)
          _GoalCard(
            goal: state.goal,
            year: state.year,
            onEdit: canSetGoal ? onEditGoal : null,
            onRemove: canSetGoal ? onRemoveGoal : null,
          ),
        if (stats.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: MuuvieEmptyState(
              illustration: MuuvieIllustration.ranking,
              title: l10n?.chartsEmptyTitle ?? '',
              message: l10n?.chartsEmptyMessage ?? '',
            ),
          )
        else ...[
          _Totals(stats: stats),
          if (retrospective != null && stats.movies > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: FilledButton.tonalIcon(
                onPressed: () => retrospective(state.year),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  l10n?.chartsOpenRetrospective('${state.year}') ?? '',
                ),
              ),
            ),
          _Section(
            title: l10n?.chartsMonths ?? '',
            child: MonthBars(
              months: stats.months,
              monthLabels: monthLabels,
              color: color,
              semanticsLabel: [
                for (final month in stats.months.where((m) => m.movies > 0))
                  '${DateFormat.MMMM(locale).format(DateTime(2000, month.month))}: ${month.movies}',
              ].join(', '),
            ),
          ),
          if (stats.genres.isNotEmpty)
            _Section(
              title: l10n?.chartsGenres ?? '',
              child: DonutChart(
                entries: [
                  for (final genre in stats.genres)
                    ChartEntry(genre.label ?? genre.key, genre.movies),
                ],
                othersLabel: l10n?.chartsOthers ?? '',
                palette: palette,
              ),
            ),
          if (stats.decades.isNotEmpty)
            _Section(
              title: l10n?.chartsDecades ?? '',
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final decade in [
                    ...stats.decades,
                  ]..sort((a, b) => a.key.compareTo(b.key)))
                    ChartEntry(
                      l10n?.chartsDecade(decade.key) ?? decade.key,
                      decade.movies,
                    ),
                ],
              ),
            ),
          if (stats.countries.isNotEmpty)
            _Section(
              title: l10n?.chartsCountries ?? '',
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final country in stats.countries.take(ChartsScreen._top))
                    ChartEntry(
                      '${_flag(country.key)} ${country.key}',
                      country.movies,
                    ),
                ],
              ),
            ),
          if (stats.languages.isNotEmpty)
            _Section(
              title: l10n?.chartsLanguages ?? '',
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final language in stats.languages.take(
                    ChartsScreen._top,
                  ))
                    ChartEntry(language.key.toUpperCase(), language.movies),
                ],
              ),
            ),
          if (stats.venues.isNotEmpty && l10n != null)
            _Section(
              title: l10n.chartsVenues,
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final venue in stats.venues)
                    ChartEntry(switch (WatchVenue.fromWireValue(venue.key)) {
                      final WatchVenue known => l10n.watchVenue(known),
                      null => venue.key,
                    }, venue.movies),
                ],
              ),
            ),
          if (stats.directors.isNotEmpty)
            _Section(
              title: l10n?.chartsDirectors ?? '',
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final director in stats.directors.take(
                    ChartsScreen._top,
                  ))
                    ChartEntry(director.label ?? director.key, director.movies),
                ],
              ),
            ),
          if (stats.emotions.isNotEmpty && l10n != null)
            _Section(
              title: l10n.chartsEmotions,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final bucket in stats.emotions.take(12))
                    if (Emotion.fromWireValue(bucket.key) case final emotion?)
                      Chip(
                        label: Text(
                          '${l10n.emotion(emotion)} · ${bucket.movies}',
                        ),
                      ),
                ],
              ),
            ),
          if (stats.ratings.isNotEmpty && l10n != null)
            _Section(
              title: l10n.chartsRatings,
              child: HorizontalBars(
                color: color,
                entries: [
                  for (final bucket in stats.ratings)
                    if (Rating.fromWireValue(bucket.key) case final rating?)
                      ChartEntry(l10n.rating(rating), bucket.movies),
                ],
              ),
            ),
          _Section(
            title: l10n?.chartsCalendar ?? '',
            child: CalendarHeatmap(
              year: state.year,
              days: state.calendar,
              color: color,
              semanticsLabel:
                  l10n?.chartsCalendarSummary(state.calendar.length) ?? '',
            ),
          ),
        ],
      ],
    );
  }

  /// The flag emoji of an ISO 3166-1 code.
  static String _flag(String code) {
    if (code.length != 2) return '';
    final upper = code.toUpperCase();
    return String.fromCharCodes([
      0x1F1E6 + upper.codeUnitAt(0) - 0x41,
      0x1F1E6 + upper.codeUnitAt(1) - 0x41,
    ]);
  }
}

class _Totals extends StatelessWidget {
  final YearStats stats;

  const _Totals({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hours = stats.minutes ~/ 60;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _Total(value: '${stats.movies}', label: l10n?.chartsMovies ?? ''),
          _Total(value: '$hours', label: l10n?.chartsHours ?? ''),
          _Total(value: '${stats.sessions}', label: l10n?.chartsSessions ?? ''),
          _Total(
            value: '${stats.rewatches}',
            label: l10n?.chartsRewatches ?? '',
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  final String value;
  final String label;

  const _Total({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: MergeSemantics(
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final YearlyGoal? goal;
  final int year;
  final ValueChanged<YearlyGoal?>? onEdit;
  final VoidCallback? onRemove;

  const _GoalCard({
    required this.goal,
    required this.year,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = goal;
    final edit = onEdit;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: current == null
            ? Row(
                children: [
                  const Icon(Icons.flag_outlined),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n?.chartsGoalPrompt('$year') ?? '')),
                  if (edit != null)
                    TextButton(
                      onPressed: () => edit(null),
                      child: Text(l10n?.chartsGoalSet ?? ''),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(current.reached ? Icons.emoji_events : Icons.flag),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.chartsGoalProgress(
                                current.watched,
                                current.targetMovies,
                                '$year',
                              ) ??
                              '',
                          style: textTheme.titleSmall,
                        ),
                      ),
                      if (edit != null)
                        PopupMenuButton<VoidCallback>(
                          tooltip: l10n?.activityMoreOptions,
                          onSelected: (action) => action(),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: () => edit(current),
                              child: Text(l10n?.maratonaEdit ?? ''),
                            ),
                            if (onRemove != null)
                              PopupMenuItem(
                                value: onRemove!,
                                child: Text(l10n?.maratonaRemove ?? ''),
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: LinearProgressIndicator(
                      value: current.progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (current.reached)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n?.chartsGoalReached ?? '',
                        style: textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
