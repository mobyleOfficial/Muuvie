import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// A CineClube in a list (Programação, profile participations): the movie
/// of the current session, the period and the debate day.
class CineClubeCard extends StatelessWidget {
  final CineClubeSummary cineclube;
  final VoidCallback onTap;

  const CineClubeCard({
    super.key,
    required this.cineclube,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final movie = cineclube.movie;
    final debate = cineclube.debateOn;
    final soft = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CineClubePoster(
                posterPath: movie?.posterPath,
                accentColor: cineclube.accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cineclube.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (movie != null)
                      Text(
                        movie.year == null
                            ? movie.title
                            : '${movie.title} (${movie.year})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      cineclubePeriod(
                        l10n,
                        cineclube.startsOn,
                        cineclube.endsOn,
                      ),
                      style: soft,
                    ),
                    if (debate != null)
                      Text(
                        l10n?.cineclubeDebateOn(cineclubeDay(debate)) ?? '',
                        style: soft,
                      ),
                    Text(
                      [
                        if (cineclube.isCycle)
                          l10n?.cineclubeSessionsCount(
                                cineclube.totalSessions,
                              ) ??
                              '',
                        l10n?.maratonaParticipants(
                              cineclube.totalParticipants,
                            ) ??
                            '',
                      ].join(' · '),
                      style: soft,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        MaratonaBadge(
                          label: cineclube.status.label(l10n),
                          highlighted:
                              cineclube.status == CineClubeStatus.active,
                        ),
                        if (cineclube.isCycle)
                          MaratonaBadge(
                            label: l10n?.cineclubeCycle ?? '',
                            icon: Icons.repeat,
                          ),
                        if (cineclube.joined)
                          MaratonaBadge(
                            label: l10n?.maratonaJoined ?? '',
                            icon: Icons.check,
                            highlighted: true,
                          ),
                        if (cineclube.hasPassword)
                          MaratonaBadge(
                            label: l10n?.maratonaLocked ?? '',
                            icon: Icons.lock_outline,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
