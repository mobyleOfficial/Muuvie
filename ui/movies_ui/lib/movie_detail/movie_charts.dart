import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';

/// "Últimos 12 meses" (B13.5): public sessions and ratings per month as
/// paired columns. Hidden while loading, on failure or with no activity.
class MovieTimelineSection extends StatefulWidget {
  /// Database id of the movie.
  final int movieId;

  const MovieTimelineSection({super.key, required this.movieId});

  @override
  State<MovieTimelineSection> createState() => _MovieTimelineSectionState();
}

class _MovieTimelineSectionState extends State<MovieTimelineSection> {
  late final Future<Result<MovieTimeline>> _timeline =
      GetIt.I<GetMovieTimeline>()(widget.movieId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<MovieTimeline>>(
      future: _timeline,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is! Success<MovieTimeline> || result.data.isEmpty) {
          return const SizedBox.shrink();
        }
        return MovieSection(
          title: l10n?.movieTimelineTitle ?? '',
          child: TimelineChart(months: result.data.months),
        );
      },
    );
  }
}

/// Sessions and ratings per month, the current month last and in evidence.
class TimelineChart extends StatelessWidget {
  final List<MonthActivity> months;

  const TimelineChart({super.key, required this.months});

  static const double _barsHeight = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Intl.getCurrentLocale();
    final initial = DateFormat('LLLLL', locale);
    final monthName = DateFormat.yMMMM(locale);
    final highest = months.fold(
      1,
      (max, month) => math.max(max, math.max(month.sessions, month.ratings)),
    );
    final sessionsColor = colorScheme.primary;
    // The same hue lighter, so it reads in both themes.
    final ratingsColor = colorScheme.primary.withValues(alpha: 0.35);
    final totalSessions = months.fold(0, (sum, month) => sum + month.sessions);
    final totalRatings = months.fold(0, (sum, month) => sum + month.ratings);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: MuuvieRadius.largeAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Legend(
                color: sessionsColor,
                label: l10n?.movieTimelineSessions ?? '',
                total: totalSessions,
              ),
              _Legend(
                color: ratingsColor,
                label: l10n?.movieDetailReviews ?? '',
                total: totalRatings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (index, month) in months.indexed)
                Expanded(
                  child: Tooltip(
                    message:
                        l10n?.movieTimelineMonth(
                          monthName.format(month.month),
                          month.sessions,
                          month.ratings,
                        ) ??
                        '',
                    child: Semantics(
                      label: l10n?.movieTimelineMonth(
                        monthName.format(month.month),
                        month.sessions,
                        month.ratings,
                      ),
                      child: ExcludeSemantics(
                        child: Column(
                          children: [
                            SizedBox(
                              height: _barsHeight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _Bar(
                                    value: month.sessions / highest,
                                    color: sessionsColor,
                                  ),
                                  const SizedBox(width: 2),
                                  _Bar(
                                    value: month.ratings / highest,
                                    color: ratingsColor,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              initial.format(month.month).toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: index == months.length - 1
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: index == months.length - 1
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final Color color;

  const _Bar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    // A sliver stays for zero so the month still reads as a slot.
    height: math.max(value * TimelineChart._barsHeight, 2),
    decoration: BoxDecoration(
      color: value == 0 ? color.withValues(alpha: 0.2) : color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
    ),
  );
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int total;

  const _Legend({
    required this.color,
    required this.label,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$total',
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

/// Every emotion people marked, as bars proportional to the most marked;
/// the first few, then "Ver todas".
class EmotionBars extends StatefulWidget {
  final List<EmotionCount> emotions;

  const EmotionBars({super.key, required this.emotions});

  @override
  State<EmotionBars> createState() => _EmotionBarsState();
}

class _EmotionBarsState extends State<EmotionBars> {
  static const _collapsedCount = 5;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final emotions = widget.emotions;
    final mostMarked = emotions.fold(
      1,
      (max, item) => math.max(max, item.count),
    );
    final visible = _expanded
        ? emotions
        : emotions.take(_collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (final item in visible)
                Semantics(
                  label: '${l10n?.emotion(item.emotion) ?? ''}: ${item.count}',
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 112,
                            child: Text(
                              l10n?.emotion(item.emotion) ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: MuuvieRadius.pillAll,
                              child: LinearProgressIndicator(
                                value: item.count / mostMarked,
                                minHeight: 10,
                                color: colorScheme.onSecondaryContainer,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${item.count}',
                              textAlign: TextAlign.end,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (emotions.length > _collapsedCount)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? l10n?.movieDetailReadLess ?? ''
                  : l10n?.movieEmotionsAll(emotions.length) ?? '',
            ),
          ),
      ],
    );
  }
}
