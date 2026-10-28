import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

/// Poster, title and year of a movie in a Catálogo row (F14.1), with the
/// viewer's rating label, or Já assisti / Quero ver, over the poster.
class CatalogMovieCard extends StatelessWidget {
  final Movie movie;

  static const double width = 112;
  static const double posterHeight = 168;

  /// Poster, two lines of title and the year.
  static const double height = 222;

  const CatalogMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final year = movie.year;
    final empty = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant),
      ),
    );

    return Semantics(
      button: true,
      label: [
        movie.title,
        ?year,
        ?catalogStateLabel(l10n, movie.me),
      ].join(', '),
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: MuuvieRadius.mediumAll,
          onTap: () => context.router.push(
            MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
          ),
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: MuuvieRadius.mediumAll,
                      child: SizedBox(
                        width: width,
                        height: posterHeight,
                        child: movie.posterPath.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: TmdbImageUrl.buildPosterMedium(
                                  movie.posterPath,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (_, _, _) => empty,
                              )
                            : empty,
                      ),
                    ),
                    if (movie.me case final me?)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CatalogStateMark(state: me),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  movie.title,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (year != null)
                  Text(
                    year,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

/// The viewer's rating label, or else Já assisti / Quero ver, read aloud.
String? catalogStateLabel(AppLocalizations? l10n, MovieListState? state) {
  if (l10n == null || state == null) return null;
  final rating = state.rating;
  if (rating != null) return l10n.rating(rating);
  final status = state.status;
  return status == null ? null : l10n.watchStatus(status);
}

/// A round mark with the rating icon in its colors, or the shelf icon of
/// Já assisti / Quero ver.
class CatalogStateMark extends StatelessWidget {
  final MovieListState state;

  const CatalogStateMark({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rating = state.rating;
    final (
      IconData icon,
      Color background,
      Color foreground,
    ) = switch (rating) {
      final Rating rating => () {
        final (background, foreground) = MuuvieRatingBadge.colorsFor(
          rating,
          colorScheme,
        );
        return (MuuvieRatingBadge.iconFor(rating), background, foreground);
      }(),
      null => (
        state.status == WatchStatus.watched ? Icons.check : Icons.bookmark,
        colorScheme.surface,
        colorScheme.primary,
      ),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 1.5),
      ),
      child: Icon(icon, size: 14, color: foreground),
    );
  }
}
