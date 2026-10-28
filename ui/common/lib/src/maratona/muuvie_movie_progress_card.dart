import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/app_localizations.dart';
import 'package:common/src/maratona/muuvie_rating_badge.dart';
import 'package:common/src/theme/muuvie_radius.dart';
import 'package:common/src/tmdb_image_url.dart';
import 'package:common/src/vocabulary/vocabulary_labels.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Movie row with the user's progress: shelves, "assistindo agora", maratona queues.
class MuuvieMovieProgressCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? posterPath;
  final int minutesWatched;

  /// Null when TMDB has no runtime; the bar is then hidden unless completed.
  final int? runtimeMinutes;
  final bool completed;
  final Rating? rating;
  final VoidCallback? onTap;

  const MuuvieMovieProgressCard({
    super.key,
    required this.title,
    this.subtitle,
    this.posterPath,
    this.minutesWatched = 0,
    this.runtimeMinutes,
    this.completed = false,
    this.rating,
    this.onTap,
  });

  double? get _progress {
    if (completed) return 1;
    final runtime = runtimeMinutes;
    if (runtime == null || runtime <= 0) return null;
    return (minutesWatched / runtime).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = _progress;
    final progressLabel = completed
        ? l10n?.watchStatus(WatchStatus.watched)
        : runtimeMinutes != null
        ? l10n?.movieProgressMinutes(minutesWatched, runtimeMinutes!)
        : null;

    return Semantics(
      button: onTap != null,
      label: [
        title,
        subtitle,
        progressLabel,
        if (rating != null) l10n?.rating(rating!),
      ].whereType<String>().join(', '),
      child: InkWell(
        onTap: onTap,
        borderRadius: MuuvieRadius.mediumAll,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: MuuvieRadius.smallAll,
                  child: SizedBox(
                    width: 56,
                    height: 84,
                    child: posterPath == null
                        ? ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.movie_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: TmdbImageUrl.buildPosterSmall(
                              posterPath!,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (progress != null) ...[
                        ClipRRect(
                          borderRadius: MuuvieRadius.smallAll,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          if (completed) ...[
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (progressLabel != null)
                            Expanded(
                              child: Text(
                                progressLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          if (rating != null)
                            MuuvieRatingBadge(rating: rating!),
                        ],
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
