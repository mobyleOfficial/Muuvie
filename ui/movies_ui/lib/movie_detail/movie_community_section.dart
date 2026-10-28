import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_charts.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';

/// The top of the Comunidade tab (B13.2, B13.5): how many watched, want to
/// watch and keep it in public shelves; how many people gave each label, as
/// bars with counts and no average; and every emotion people marked.
class MovieCommunitySection extends StatefulWidget {
  /// Database id of the movie.
  final int movieId;

  /// Opens "Estantes com este filme"; null leaves the number inert.
  final VoidCallback? onOpenShelves;

  const MovieCommunitySection({
    super.key,
    required this.movieId,
    this.onOpenShelves,
  });

  @override
  State<MovieCommunitySection> createState() => _MovieCommunitySectionState();
}

class _MovieCommunitySectionState extends State<MovieCommunitySection> {
  late final Future<Result<MovieCommunity>> _community =
      GetIt.I<GetMovieCommunity>()(widget.movieId);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<Result<MovieCommunity>>(
      future: _community,
      builder: (context, snapshot) {
        // While loading, or when the request fails, the section stays hidden:
        // zeros would read as "nobody watched it".
        final result = snapshot.data;
        if (result is! Success<MovieCommunity>) return const SizedBox.shrink();
        final community = result.data;
        final ratings = [
          for (final rating in Rating.values)
            if ((community.ratings[rating] ?? 0) > 0)
              (rating, community.ratings[rating]!),
        ];
        final mostGiven = ratings.fold(
          0,
          (max, entry) => entry.$2 > max ? entry.$2 : max,
        );
        final onOpenShelves = widget.onOpenShelves;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.visibility_outlined,
                      value: community.watched,
                      label: l10n?.movieStatWatched ?? '',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.bookmark_border,
                      value: community.wantToWatch,
                      label: l10n?.movieStatWantToWatch ?? '',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.collections_bookmark_outlined,
                      value: community.shelves,
                      label: l10n?.movieStatShelves ?? '',
                      onTap: community.shelves > 0 ? onOpenShelves : null,
                    ),
                  ),
                ],
              ),
            ),
            if (community.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  l10n?.movieCommunityEmpty ?? '',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (ratings.isNotEmpty)
              MovieSection(
                title: l10n?.movieDetailReviews ?? '',
                child: _Card(
                  child: Column(
                    children: [
                      for (final (rating, count) in ratings)
                        _RatingBar(
                          rating: rating,
                          count: count,
                          mostGiven: mostGiven,
                        ),
                    ],
                  ),
                ),
              ),
            if (community.emotions.isNotEmpty)
              MovieSection(
                title: l10n?.movieCommunityFeelings ?? '',
                child: _Card(child: EmotionBars(emotions: community.emotions)),
              ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: MuuvieRadius.largeAll,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// A big number over its label; a chevron when it opens something.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final VoidCallback? onTap;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onTap = this.onTap;

    return Semantics(
      button: onTap != null,
      label: '$value $label',
      child: ExcludeSemantics(
        child: Material(
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: MuuvieRadius.largeAll,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
                      const Spacer(),
                      if (onTap != null)
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$value',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onTap == null
                          ? colorScheme.onSurface
                          : colorScheme.primary,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One label with a bar proportional to the most given one.
class _RatingBar extends StatelessWidget {
  final Rating rating;
  final int count;
  final int mostGiven;

  const _RatingBar({
    required this.rating,
    required this.count,
    required this.mostGiven,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = MuuvieRatingBadge.colorsFor(
      rating,
      colorScheme,
    );
    final label = l10n?.rating(rating) ?? '';

    return Semantics(
      label: '$label: $count',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: background,
                child: Icon(
                  MuuvieRatingBadge.iconFor(rating),
                  size: 14,
                  color: foreground,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 104,
                child: Text(
                  label,
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
                    value: mostGiven == 0 ? 0 : count / mostGiven,
                    minHeight: 10,
                    color: foreground,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$count',
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
    );
  }
}
