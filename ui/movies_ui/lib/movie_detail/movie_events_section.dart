import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';

/// "Na Programação" on the movie detail (F12.1): open maratonas the movie
/// counts for, with the challenges it completes. CineClubes, open or not,
/// have their own row (B13.5). Hidden when there is none.
class MovieEventsSection extends StatefulWidget {
  /// Database id of the movie.
  final int movieId;
  final MovieDetailLinks links;

  const MovieEventsSection({
    super.key,
    required this.movieId,
    required this.links,
  });

  @override
  State<MovieEventsSection> createState() => _MovieEventsSectionState();
}

class _MovieEventsSectionState extends State<MovieEventsSection> {
  late final Future<Result<MovieEvents>> _events = GetIt.I<GetMovieEvents>()(
    widget.movieId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<MovieEvents>>(
      future: _events,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is! Success<MovieEvents> || result.data.maratonas.isEmpty) {
          return const SizedBox.shrink();
        }
        return MovieSection(
          title: l10n?.movieEventsTitle ?? '',
          child: Column(
            children: [
              for (final event in result.data.maratonas)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MovieEventCard.maratona(
                    event: event,
                    onTap: () => widget.links.openMaratona(context, event),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A maratona or CineClube in the event's own color: title, status and
/// period, and the challenges the movie completes. [compact] fits a row
/// that scrolls sideways.
class MovieEventCard extends StatelessWidget {
  final MovieEvent event;
  final IconData icon;

  /// "Maratonas" or "CineClubes", for the screen reader.
  final String Function(AppLocalizations? l10n) kind;

  /// The finished label agrees with the kind ("Finalizada", "Encerrado").
  final String Function(AppLocalizations? l10n) finished;
  final VoidCallback onTap;
  final bool compact;

  const MovieEventCard.maratona({
    super.key,
    required this.event,
    required this.onTap,
    this.compact = false,
  }) : icon = Icons.emoji_events_outlined,
       kind = _maratonas,
       finished = _maratonaFinished;

  const MovieEventCard.cineclube({
    super.key,
    required this.event,
    required this.onTap,
    this.compact = false,
  }) : icon = Icons.groups_outlined,
       kind = _cineclubes,
       finished = _cineclubeFinished;

  static String _maratonas(AppLocalizations? l10n) =>
      l10n?.programacaoMaratonasTab ?? '';
  static String _cineclubes(AppLocalizations? l10n) =>
      l10n?.programacaoCineClubesTab ?? '';
  static String _maratonaFinished(AppLocalizations? l10n) =>
      l10n?.maratonaStatusFinished ?? '';
  static String _cineclubeFinished(AppLocalizations? l10n) =>
      l10n?.cineclubeStatusFinished ?? '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final finished = event.isFinished;
    // A finished event loses its color, so the live ones stand out.
    final color = finished
        ? colorScheme.surfaceContainerHighest
        : MuuvieColorPicker.fromHex(event.accentColor) ?? colorScheme.primary;
    final onColor = finished
        ? colorScheme.onSurfaceVariant
        : color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final format = DateFormat.yMMMd(Intl.getCurrentLocale());
    final status = finished
        ? this.finished(l10n)
        : event.isUpcoming
        ? l10n?.maratonaStatusUpcoming ?? ''
        : l10n?.maratonaStatusActive ?? '';
    final period =
        l10n?.maratonaPeriod(
          format.format(event.startsOn),
          format.format(event.endsOn),
        ) ??
        '';

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          event.title,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: '${kind(l10n)}: ${event.title}',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        _StatusPill(label: status, live: !finished && !event.isUpcoming),
        const SizedBox(height: 4),
        Text(
          [period, if (event.joined) l10n?.maratonaJoined ?? ''].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (event.challenges.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            l10n?.movieEventCountsFor(event.challenges.join(', ')) ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return SizedBox(
      width: compact ? 240 : null,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: MuuvieRadius.largeAll,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The event's own color marks the card.
                Container(width: 6, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: CircleAvatar(
                            backgroundColor: color,
                            child: Icon(icon, color: onColor, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: details),
                        if (!compact)
                          ExcludeSemantics(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Icon(
                                Icons.chevron_right,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
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

class _StatusPill extends StatelessWidget {
  final String label;

  /// Happening now: in evidence.
  final bool live;

  const _StatusPill({required this.label, required this.live});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: live
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: MuuvieRadius.pillAll,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: live
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
