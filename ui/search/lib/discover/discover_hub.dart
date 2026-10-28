import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_section.dart';
import 'package:profile/profile.dart';
import 'package:shelves/shelves.dart';

import 'package:search/discover/catalog_movie_card.dart';
import 'package:search/discover/discover_list_page.dart';
import 'package:search/discover/discover_widgets.dart';
import 'package:search/muuvie_ranking/muuvie_ranking_page.dart';
import 'package:search/search_router.dart';

/// The Catálogo when nothing is typed (F5.6, F14.1): genres, the movies of
/// the Muuvie and the new releases, the community's shelves, locadoras and
/// cinéfilos, and the ways to browse the catalog.
class DiscoverHub extends StatefulWidget {
  const DiscoverHub({super.key});

  @override
  State<DiscoverHub> createState() => _DiscoverHubState();
}

class _DiscoverHubState extends State<DiscoverHub> {
  // Releases of the last weeks, the closest to "em cartaz" TMDB discover offers.
  static const _releaseWindow = Duration(days: 45);
  static const _sortByPopularity = 'popularity.desc';

  late final String _releaseDateGte;
  late final String _releaseDateLte;

  late Future<Result<List<Genre>>> _genres;
  late Future<Result<MovieListing>> _trending;
  late Future<Result<MovieListing>> _releases;
  late Future<Result<MovieListing>> _loved;
  late Future<Result<Paged<Shelf>>> _shelves;
  late Future<Result<Paged<Locadora>>> _locadoras;
  late Future<Result<Paged<ProfileCard>>> _profiles;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    String date(DateTime day) => day.toIso8601String().substring(0, 10);
    _releaseDateGte = date(today.subtract(_releaseWindow));
    _releaseDateLte = date(today);
    _genres = _loadGenres();
    _trending = _loadTrending();
    _releases = _loadReleases();
    _loved = _loadLoved();
    _shelves = _loadShelves();
    _locadoras = _loadLocadoras();
    _profiles = _loadProfiles();
  }

  Future<Result<List<Genre>>> _loadGenres() => GetIt.I<GetGenres>()();

  Future<Result<MovieListing>> _loadTrending() =>
      GetIt.I<GetTrendingOnMuuvie>()();

  Future<Result<MovieListing>> _loadReleases() => GetIt.I<DiscoverMovies>()(
    DiscoverMoviesParams(
      releaseDateGte: _releaseDateGte,
      releaseDateLte: _releaseDateLte,
      sortBy: _sortByPopularity,
    ),
  );

  Future<Result<MovieListing>> _loadLoved() =>
      GetIt.I<GetMostLovedOnMuuvie>()();

  Future<Result<Paged<Shelf>>> _loadShelves() => GetIt.I<DiscoverShelves>()();

  Future<Result<Paged<Locadora>>> _loadLocadoras() =>
      GetIt.I<DiscoverLocadoras>()();

  Future<Result<Paged<ProfileCard>>> _loadProfiles() =>
      GetIt.I<DiscoverProfiles>()();

  Future<void> _refresh() async {
    setState(() {
      _genres = _loadGenres();
      _trending = _loadTrending();
      _releases = _loadReleases();
      _loved = _loadLoved();
      _shelves = _loadShelves();
      _locadoras = _loadLocadoras();
      _profiles = _loadProfiles();
    });
    await Future.wait([
      _genres,
      _trending,
      _releases,
      _loved,
      _shelves,
      _locadoras,
      _profiles,
    ]);
  }

  void _openGenre(Genre genre) => context.router.push(
    ReleaseDateMoviesRoute(
      title: genre.name,
      withGenres: '${genre.id}',
      sortBy: _sortByPopularity,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // A Column, not a lazy ListView: a row rebuilt off screen shows its tall
    // placeholders for a frame before going back to the error or empty state,
    // and that change of height above the viewport undid the scroll up.
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GenreChips(future: _genres, onTap: _openGenre),
            _HubRow<MovieListing>(
              title: l10n?.discoverTrending ?? '',
              future: _trending,
              isEmpty: (listing) => listing.movies.isEmpty,
              onRetry: () => setState(() {
                _trending = _loadTrending();
              }),
              height: CatalogMovieCard.height,
              itemWidth: CatalogMovieCard.width,
              onSeeAll: () => context.router.push(
                MuuvieRankingRoute(ranking: MuuvieRanking.trending),
              ),
              builder: (listing) => [
                for (final movie in listing.movies)
                  CatalogMovieCard(movie: movie),
              ],
            ),
            _HubRow<MovieListing>(
              title: l10n?.discoverReleases ?? '',
              future: _releases,
              isEmpty: (listing) => listing.movies.isEmpty,
              onRetry: () => setState(() {
                _releases = _loadReleases();
              }),
              height: CatalogMovieCard.height,
              itemWidth: CatalogMovieCard.width,
              onSeeAll: () => context.router.push(
                ReleaseDateMoviesRoute(
                  title: l10n?.discoverReleases ?? '',
                  releaseDateGte: _releaseDateGte,
                  releaseDateLte: _releaseDateLte,
                  sortBy: _sortByPopularity,
                ),
              ),
              builder: (listing) => [
                for (final movie in listing.movies)
                  CatalogMovieCard(movie: movie),
              ],
            ),
            _HubRow<MovieListing>(
              title: l10n?.discoverMostLoved ?? '',
              future: _loved,
              isEmpty: (listing) => listing.movies.isEmpty,
              onRetry: () => setState(() {
                _loved = _loadLoved();
              }),
              height: CatalogMovieCard.height,
              itemWidth: CatalogMovieCard.width,
              onSeeAll: () => context.router.push(
                MuuvieRankingRoute(ranking: MuuvieRanking.loved),
              ),
              builder: (listing) => [
                for (final movie in listing.movies)
                  CatalogMovieCard(movie: movie),
              ],
            ),
            _HubRow<Paged<Shelf>>(
              title: l10n?.discoverShelves ?? '',
              future: _shelves,
              isEmpty: (page) => page.items.isEmpty,
              onRetry: () => setState(() {
                _shelves = _loadShelves();
              }),
              height: 168,
              itemWidth: 260,
              onSeeAll: () => context.router.push(
                DiscoverListRoute(kind: DiscoverKind.shelves),
              ),
              builder: (page) => [
                for (final shelf in page.items)
                  SizedBox(
                    width: 260,
                    child: DiscoveredShelfCard(shelf: shelf),
                  ),
              ],
            ),
            _HubRow<Paged<Locadora>>(
              title: l10n?.discoverLocadoras ?? '',
              future: _locadoras,
              isEmpty: (page) => page.items.isEmpty,
              onRetry: () => setState(() {
                _locadoras = _loadLocadoras();
              }),
              height: 168,
              itemWidth: 260,
              onSeeAll: () => context.router.push(
                DiscoverListRoute(kind: DiscoverKind.locadoras),
              ),
              builder: (page) => [
                for (final locadora in page.items)
                  SizedBox(
                    width: 260,
                    child: DiscoveredLocadoraCard(locadora: locadora),
                  ),
              ],
            ),
            _HubRow<Paged<ProfileCard>>(
              title: l10n?.discoverProfiles ?? '',
              future: _profiles,
              isEmpty: (page) => page.items.isEmpty,
              onRetry: () => setState(() {
                _profiles = _loadProfiles();
              }),
              height: 116,
              itemWidth: 88,
              onSeeAll: () => context.router.push(
                DiscoverListRoute(kind: DiscoverKind.profiles),
              ),
              builder: (page) => [
                for (final profile in page.items)
                  _ProfileBubble(profile: profile),
              ],
            ),
            MovieSection(
              title: l10n?.discoverExplore ?? '',
              child: _ExploreGrid(
                items: [
                  (
                    Icons.calendar_today_outlined,
                    l10n?.searchBrowseReleaseDate ?? '',
                    const ReleaseDateDecadesRoute(),
                  ),
                  (
                    Icons.category_outlined,
                    l10n?.searchBrowseGenreCountryLanguage ?? '',
                    const BrowseCategoriesRoute(),
                  ),
                  (
                    Icons.trending_up,
                    l10n?.searchBrowseMostPopular ?? '',
                    const MostPopularRoute(),
                  ),
                  (
                    Icons.schedule,
                    l10n?.searchBrowseMostAnticipated ?? '',
                    const MostAnticipatedRoute(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The genres in pills that scroll sideways; hidden while they load or fail.
class _GenreChips extends StatelessWidget {
  final Future<Result<List<Genre>>> future;
  final ValueChanged<Genre> onTap;

  const _GenreChips({required this.future, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<List<Genre>>>(
      future: future,
      builder: (context, snapshot) => switch (snapshot.data) {
        Success(:final data) when data.isNotEmpty => Semantics(
          label: l10n?.discoverGenres,
          container: true,
          child: SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: data.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = data[index];
                return ActionChip(
                  label: Text(genre.name),
                  shape: const StadiumBorder(),
                  side: BorderSide(color: colorScheme.outlineVariant),
                  onPressed: () => onTap(genre),
                );
              },
            ),
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

/// A titled horizontal row (F14.1): placeholders of the card size while it
/// loads, "try again" when it fails, and hidden when it comes empty.
class _HubRow<T> extends StatelessWidget {
  final String title;
  final Future<Result<T>> future;
  final bool Function(T) isEmpty;
  final VoidCallback onRetry;
  final double height;
  final double itemWidth;
  final List<Widget> Function(T) builder;
  final VoidCallback? onSeeAll;

  const _HubRow({
    required this.title,
    required this.future,
    required this.isEmpty,
    required this.onRetry,
    required this.height,
    required this.itemWidth,
    required this.builder,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Result<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MovieSection(
            title: title,
            padContent: false,
            child: _Placeholders(height: height, itemWidth: itemWidth),
          );
        }
        return switch (snapshot.data) {
          Success(:final data) when !isEmpty(data) => () {
            final items = builder(data);
            return MovieSection(
              title: title,
              actionLabel: onSeeAll == null ? null : l10n?.profileSeeAll,
              onAction: onSeeAll,
              padContent: false,
              child: SizedBox(
                height: height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => items[index],
                ),
              ),
            );
          }(),
          Success() => const SizedBox.shrink(),
          _ => MovieSection(
            title: title,
            child: _SectionError(onRetry: onRetry),
          ),
        };
      },
    );
  }
}

/// Grey cards in the size of the row's items while it loads.
class _Placeholders extends StatelessWidget {
  final double height;
  final double itemWidth;

  const _Placeholders({required this.height, required this.itemWidth});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, _) => Container(
            width: itemWidth,
            decoration: BoxDecoration(
              color: color,
              borderRadius: MuuvieRadius.mediumAll,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final VoidCallback onRetry;

  const _SectionError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n?.discoverSectionError ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: Text(l10n?.emptyStateRetry ?? ''),
        ),
      ],
    );
  }
}

/// The ways to browse the catalog, two per line.
class _ExploreGrid extends StatelessWidget {
  final List<(IconData, String, PageRouteInfo)> items;

  const _ExploreGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        for (final (icon, label, route) in items)
          Material(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: MuuvieRadius.mediumAll,
            child: InkWell(
              borderRadius: MuuvieRadius.mediumAll,
              onTap: () => context.router.push(route),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ExcludeSemantics(
                      child: Icon(icon, color: colorScheme.primary),
                    ),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileBubble extends StatelessWidget {
  final ProfileCard profile;

  const _ProfileBubble({required this.profile});

  @override
  Widget build(BuildContext context) {
    final handle = profile.handle;
    return SizedBox(
      width: 88,
      child: InkWell(
        borderRadius: MuuvieRadius.smallAll,
        onTap: () => openProfile(context, profile.id, name: profile.name),
        child: Column(
          children: [
            ProfileAvatar(
              url: profile.avatarUrl,
              accent: profile.accentColor,
              radius: 32,
            ),
            const SizedBox(height: 6),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (handle != null)
              Text(
                '@$handle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
