import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_charts.dart';
import 'package:movies_ui/movie_detail/movie_community_section.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:movies_ui/movie_detail/movie_events_section.dart';
import 'package:movies_ui/movie_detail/paged_row_section.dart';
import 'package:movies_ui/movie_detail/recent_ratings_section.dart';
import 'package:shelves/shelves.dart';

/// "Comunidade" of the movie detail (B13.5): the movie in Muuvie. The
/// numbers, ratings and emotions, the last months, recent ratings, then the
/// shelves, maratonas and CineClubes it is in.
class MovieCommunityTab extends StatefulWidget {
  final Movie detail;
  final MovieDetailLinks? links;

  /// Bumped when the user rates or logs, to reload what they changed.
  final int version;

  /// "Ver todas" of the recent ratings: the Atividade tab on Avaliações.
  final VoidCallback onSeeAllRatings;

  const MovieCommunityTab({
    super.key,
    required this.detail,
    this.links,
    required this.version,
    required this.onSeeAllRatings,
  });

  @override
  State<MovieCommunityTab> createState() => _MovieCommunityTabState();
}

class _MovieCommunityTabState extends State<MovieCommunityTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    final detail = widget.detail;
    final movieId = detail.id;
    final links = widget.links;
    final version = widget.version;

    return CustomScrollView(
      key: const PageStorageKey('community'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MovieCommunitySection(
                key: ValueKey('community$version'),
                movieId: movieId,
                onOpenShelves: links == null
                    ? null
                    : () => links.openMovieShelves(context, detail),
              ),
              MovieTimelineSection(
                key: ValueKey('timeline$version'),
                movieId: movieId,
              ),
              RecentRatingsSection(
                key: ValueKey('ratings$version'),
                movieId: movieId,
                onSeeAll: widget.onSeeAllRatings,
              ),
              if (links != null) ...[
                PagedRowSection<PublicShelf>(
                  title: l10n?.movieShelvesSection ?? '',
                  actionLabel: l10n?.movieRecentRatingsAll ?? '',
                  onAction: () => links.openMovieShelves(context, detail),
                  height: 196,
                  loadPage: (page) async =>
                      switch (await GetIt.I<GetPublicShelvesWithMovie>()(
                        PublicShelvesParams(movieId: movieId, page: page),
                      )) {
                        Success(:final data) => Success((
                          items: data.items,
                          hasNext: data.hasNext,
                        )),
                        Failure(:final error) => Failure(error),
                      },
                  itemBuilder: (context, item) => _ShelfCard(
                    item: item,
                    onTap: () => links.openShelf(
                      context,
                      shelfId: item.shelf.id,
                      shelfName: item.shelf.name,
                      shelfColor: item.shelf.color,
                    ),
                  ),
                ),
                MovieEventsSection(movieId: movieId, links: links),
                PagedRowSection<MovieEvent>(
                  title: l10n?.programacaoCineClubesTab ?? '',
                  height: 128,
                  loadPage: (page) =>
                      _eventPage(GetIt.I<GetMovieCineClubes>(), movieId, page),
                  itemBuilder: (context, event) => MovieEventCard.cineclube(
                    event: event,
                    compact: true,
                    onTap: () => links.openCineClube(context, event),
                  ),
                ),
                PagedRowSection<MovieEvent>(
                  title: l10n?.movieMaratonasSection ?? '',
                  height: 128,
                  loadPage: (page) =>
                      _eventPage(GetIt.I<GetMovieMaratonas>(), movieId, page),
                  itemBuilder: (context, event) => MovieEventCard.maratona(
                    event: event,
                    compact: true,
                    onTap: () => links.openMaratona(context, event),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  static Future<Result<RowPage<MovieEvent>>> _eventPage(
    UseCase<MovieEventPageParams, Result<MovieEventPage>> load,
    int movieId,
    int page,
  ) async => switch (await load(
    MovieEventPageParams(movieId: movieId, page: page),
  )) {
    Success(:final data) => Success((items: data.items, hasNext: data.hasNext)),
    Failure(:final error) => Failure(error),
  };
}

/// A shelf as a fan of its first posters over its color, with its owner.
class _ShelfCard extends StatelessWidget {
  final PublicShelf item;
  final VoidCallback onTap;

  const _ShelfCard({required this.item, required this.onTap});

  static const double _width = 168;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shelf = item.shelf;
    final color =
        MuuvieColorPicker.fromHex(shelf.color) ??
        colorScheme.surfaceContainerHighest;
    final posters = shelf.posterPaths.take(3).toList();

    return Semantics(
      button: true,
      label: '${shelf.name}, ${l10n?.movieShelvesBy(item.ownerName) ?? ''}',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: MuuvieRadius.mediumAll,
          onTap: onTap,
          child: SizedBox(
            width: _width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 120,
                  width: _width,
                  decoration: BoxDecoration(
                    borderRadius: MuuvieRadius.mediumAll,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.55)],
                    ),
                  ),
                  child: posters.isEmpty
                      ? Icon(
                          Icons.collections_bookmark_outlined,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : Stack(
                          children: [
                            // The first poster in front, the others peeking.
                            for (final (index, path)
                                in posters.indexed.toList().reversed)
                              Positioned(
                                left: 14.0 + index * 40,
                                top: 10.0 + index * 4,
                                child: _MiniPoster(path: path),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  shelf.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [
                    l10n?.movieShelvesBy(item.ownerName) ?? '',
                    l10n?.shelfMoviesCount(shelf.totalMovies) ?? '',
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

class _MiniPoster extends StatelessWidget {
  final String path;

  const _MiniPoster({required this.path});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final empty = Container(color: colorScheme.surfaceContainerHighest);

    return Container(
      width: 66,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: MuuvieRadius.smallAll,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: MuuvieRadius.smallAll,
        child: path.isEmpty
            ? empty
            : CachedNetworkImage(
                imageUrl: TmdbImageUrl.buildPosterSmall(path),
                fit: BoxFit.cover,
                placeholder: (_, _) => empty,
                errorWidget: (_, _, _) => empty,
              ),
      ),
    );
  }
}
