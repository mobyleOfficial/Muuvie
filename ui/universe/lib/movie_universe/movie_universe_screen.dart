import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:shelves/shelves.dart' show PublicShelf;
import 'package:universe_ui/movie_universe/filter/constellation_shelves.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/map/universe_map.dart';
import 'package:universe_ui/movie_universe/movie_universe_bloc.dart';
import 'package:universe_ui/movie_universe/movie_universe_state.dart';

/// Universo de Filmes: the star map of the movie the user started from, or
/// the system in focus as a list, for screen readers and for whoever
/// prefers it.
class MovieUniverseScreen extends StatelessWidget {
  final MovieUniverseCubit cubit;
  final ValueChanged<Movie> onOpenMovie;
  final ValueChanged<Movie> onAddToWatchlist;
  final ValueChanged<Movie> onAddToShelves;
  final VoidCallback onShareRoute;

  const MovieUniverseScreen({
    super.key,
    required this.cubit,
    required this.onOpenMovie,
    required this.onAddToWatchlist,
    required this.onAddToShelves,
    required this.onShareRoute,
  });

  void _showFilters(BuildContext context) {
    cubit.loadConstellations();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<MovieUniverseCubit, MovieUniverseState>(
        bloc: cubit,
        builder: (_, state) => state is MovieUniverseExploring
            ? _FilterSheet(
                filter: state.filter,
                options: UniverseFilterOptions.of(state.graph),
                onChanged: cubit.setFilter,
                starTitle: state.currentSystem.star.displayTitle,
                constellations:
                    state.constellationShelves?.starId == state.currentStarId
                    ? state.constellationShelves
                    : null,
                buildingConstellationId: state.buildingConstellationId,
                onConstellation: cubit.showConstellation,
                onRetryConstellations: cubit.loadConstellations,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<MovieUniverseCubit, MovieUniverseState>(
      bloc: cubit,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(l10n?.universeTitle(cubit.origin.displayTitle) ?? ''),
          actions: [
            if (state is MovieUniverseExploring)
              IconButton(
                tooltip: l10n?.universeFilter,
                isSelected: state.filter.isActive,
                icon: Badge(
                  isLabelVisible: state.filter.isActive,
                  child: const Icon(Icons.filter_list),
                ),
                onPressed: () => _showFilters(context),
              ),
            if (state is MovieUniverseExploring)
              IconButton(
                tooltip: state.showAsList
                    ? l10n?.universeShowMap
                    : l10n?.universeShowList,
                icon: Icon(
                  state.showAsList
                      ? Icons.blur_circular_outlined
                      : Icons.view_list_outlined,
                ),
                onPressed: cubit.toggleView,
              ),
          ],
        ),
        body: switch (state) {
          MovieUniverseLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          MovieUniverseEmpty() => _Message(
            icon: Icons.brightness_low_outlined,
            text: l10n?.universeEmpty ?? '',
          ),
          MovieUniverseFailure() => _Message(
            icon: Icons.cloud_off_outlined,
            text: l10n?.universeError ?? '',
            actionLabel: l10n?.retry,
            onAction: cubit.load,
          ),
          MovieUniverseExploring(showAsList: true) => _UniverseList(
            state: state,
            onOpenMovie: onOpenMovie,
            onTravel: cubit.travelTo,
            onBackToOrigin: cubit.backToOrigin,
            onShareRoute: onShareRoute,
            onClearFilter: () => cubit.setFilter(UniverseFilter.none),
            onAddToWatchlist: onAddToWatchlist,
            onAddToShelves: onAddToShelves,
          ),
          MovieUniverseExploring() => Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label: l10n?.universeMapLabel(
                    state.currentSystem.planets.length,
                    state.currentSystem.star.displayTitle,
                  ),
                  child: ExcludeSemantics(
                    child: UniverseMap(
                      graph: state.graph,
                      currentStarId: state.currentStarId,
                      selected: state.selected,
                      filter: state.filter,
                      onSelect: cubit.select,
                      onFocusSystem: cubit.focusSystem,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    if (state.currentSystem.hops > 0)
                      _HopsBar(
                        hops: state.currentSystem.hops,
                        onBackToOrigin: cubit.backToOrigin,
                        onShareRoute: onShareRoute,
                      ),
                    if (state.filter.isActive)
                      _FilterBar(
                        filter: state.filter,
                        matching: state.matchingPlanets.length,
                        total: state.currentSystem.planets.length,
                        onClear: () => cubit.setFilter(UniverseFilter.none),
                      ),
                  ],
                ),
              ),
              if (state.selected case final selected?)
                if (state.graph.planetOf(selected.id) case final planet?)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      child: _PlanetCard(
                        planet: planet,
                        traveling: state.travelingTo?.id == selected.id,
                        onOpen: () => onOpenMovie(planet.movie),
                        onTravel: () => cubit.travelTo(planet.movie),
                        onAddToWatchlist: () => onAddToWatchlist(planet.movie),
                        onAddToShelves: () => onAddToShelves(planet.movie),
                      ),
                    ),
                  ),
            ],
          ),
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// How far the system in focus is from the origin, and the way back.
class _HopsBar extends StatelessWidget {
  final int hops;
  final VoidCallback onBackToOrigin;
  final VoidCallback onShareRoute;

  const _HopsBar({
    required this.hops,
    required this.onBackToOrigin,
    required this.onShareRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            const ExcludeSemantics(child: Icon(Icons.route_outlined, size: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n?.universeHops(hops) ?? '')),
            IconButton(
              tooltip: l10n?.universeShareRoute,
              icon: const Icon(Icons.share_outlined),
              onPressed: onShareRoute,
            ),
            TextButton.icon(
              onPressed: onBackToOrigin,
              icon: const Icon(Icons.home_outlined),
              label: Text(l10n?.universeBackToOrigin ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card of the selected planet, over the map: what it is, why it is
/// here, and what to do with it.
class _PlanetCard extends StatelessWidget {
  final OrbitingPlanet planet;
  final bool traveling;
  final VoidCallback onOpen;
  final VoidCallback onTravel;
  final VoidCallback onAddToWatchlist;
  final VoidCallback onAddToShelves;

  const _PlanetCard({
    required this.planet,
    required this.traveling,
    required this.onOpen,
    required this.onTravel,
    required this.onAddToWatchlist,
    required this.onAddToShelves,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final movie = planet.movie;
    final year = movie.year;
    final status = movie.me?.status;
    final inCommon = _inCommon(context, planet.similar);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Poster(movie: movie, width: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                      if (year != null) Text(year, style: textTheme.bodySmall),
                      if (status != null) _StatusLabel(status: status),
                      if (inCommon != null)
                        Text(
                          l10n?.universeInCommon(inCommon) ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    child: Text(l10n?.universeOpenDetails ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: traveling ? null : onTravel,
                    icon: traveling
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch_outlined),
                    label: Text(l10n?.universeTravel ?? ''),
                  ),
                ),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                if (status == null)
                  TextButton.icon(
                    onPressed: onAddToWatchlist,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(l10n?.universeWantToWatch ?? ''),
                  ),
                TextButton.icon(
                  onPressed: onAddToShelves,
                  icon: const Icon(Icons.playlist_add),
                  label: Text(l10n?.universeAddToShelf ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Up to four of the genres and keywords a planet shares with its star,
/// comma-separated; null when it shares none or they are unknown.
///
/// TMDB keywords exist only in English, so they are listed only when the app
/// is in English; in other languages they still weigh in the score, but the
/// text names the genres alone instead of mixing two languages.
String? _inCommon(BuildContext context, SimilarMovie similar) {
  const shown = 4;
  final inEnglish = Localizations.localeOf(context).languageCode == 'en';
  final shared = [
    ...similar.sharedGenres,
    if (inEnglish) ...similar.sharedKeywords,
  ];
  if (shared.isEmpty) return null;
  final listed = shared.take(shown).join(', ');
  return shared.length > shown ? '$listed…' : listed;
}

/// Já assisti or Quero ver, as an icon and its words: the map badge in
/// text.
class _StatusLabel extends StatelessWidget {
  final WatchStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (icon, label) = switch (status) {
      WatchStatus.watched => (Icons.check_circle, l10n?.systemShelfWatched),
      WatchStatus.wantToWatch => (Icons.bookmark, l10n?.systemShelfWatchlist),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 16)),
        const SizedBox(width: 4),
        Text(label ?? '', style: textTheme.labelMedium),
      ],
    );
  }
}

/// How many planets of the system in focus the filter keeps, and the way to
/// clear it.
class _FilterBar extends StatelessWidget {
  final UniverseFilter filter;
  final int matching;
  final int total;
  final VoidCallback onClear;

  const _FilterBar({
    required this.filter,
    required this.matching,
    required this.total,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            const ExcludeSemantics(child: Icon(Icons.filter_list, size: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                (filter.constellation != null
                        ? l10n?.universeConstellationSummary(
                            filter.constellation!.name,
                            matching,
                            total,
                          )
                        : l10n?.universeFilterSummary(matching, total)) ??
                    '',
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(l10n?.universeFilterClear ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

/// What stands out: only the unwatched, one decade, one genre, and one
/// public shelf holding the star in focus as a constellation. Each change
/// applies at once, so the map behind updates as the user picks.
class _FilterSheet extends StatelessWidget {
  final UniverseFilter filter;
  final UniverseFilterOptions options;
  final ValueChanged<UniverseFilter> onChanged;
  final String starTitle;
  final ConstellationShelves? constellations;
  final int? buildingConstellationId;
  final ValueChanged<PublicShelf> onConstellation;
  final VoidCallback onRetryConstellations;

  const _FilterSheet({
    required this.filter,
    required this.options,
    required this.onChanged,
    required this.starTitle,
    required this.constellations,
    required this.buildingConstellationId,
    required this.onConstellation,
    required this.onRetryConstellations,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    Widget section(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: textTheme.titleSmall),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Semantics(
                header: true,
                child: Text(
                  l10n?.universeFilter ?? '',
                  style: textTheme.titleLarge,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(l10n?.universeFilterOnlyUnwatched ?? ''),
              value: filter.onlyUnwatched,
              onChanged: (value) => onChanged(filter.withOnlyUnwatched(value)),
            ),
            if (options.decades.isNotEmpty)
              section(l10n?.universeFilterDecade ?? '', [
                ChoiceChip(
                  label: Text(l10n?.universeFilterAny ?? ''),
                  selected: filter.decade == null,
                  onSelected: (_) => onChanged(filter.withDecade(null)),
                ),
                for (final decade in options.decades)
                  ChoiceChip(
                    label: Text(l10n?.universeFilterDecadeValue(decade) ?? ''),
                    selected: filter.decade == decade,
                    onSelected: (_) => onChanged(filter.withDecade(decade)),
                  ),
              ]),
            if (options.genres.isNotEmpty)
              section(l10n?.universeFilterGenre ?? '', [
                ChoiceChip(
                  label: Text(l10n?.universeFilterAny ?? ''),
                  selected: filter.genre == null,
                  onSelected: (_) => onChanged(filter.withGenre(null)),
                ),
                for (final genre in options.genres)
                  ChoiceChip(
                    label: Text(genre),
                    selected: filter.genre == genre,
                    onSelected: (_) => onChanged(filter.withGenre(genre)),
                  ),
              ]),
            section(l10n?.universeConstellations ?? '', [
              Text(
                l10n?.universeConstellationsHelp(starTitle) ?? '',
                style: textTheme.bodySmall,
              ),
              ...switch (constellations) {
                null || ConstellationShelvesLoading() => [
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                ConstellationShelvesFailed() => [
                  Text(l10n?.universeConstellationsError ?? ''),
                  TextButton(
                    onPressed: onRetryConstellations,
                    child: Text(l10n?.retry ?? ''),
                  ),
                ],
                ConstellationShelvesLoaded(:final shelves)
                    when shelves.isEmpty =>
                  [Text(l10n?.universeConstellationsEmpty(starTitle) ?? '')],
                ConstellationShelvesLoaded(:final shelves) => [
                  for (final shelf in shelves)
                    FilterChip(
                      avatar: buildingConstellationId == shelf.shelf.id
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      label: Text(
                        l10n?.universeConstellationLabel(
                              shelf.shelf.name,
                              shelf.ownerName,
                            ) ??
                            '',
                      ),
                      selected: filter.constellation?.shelfId == shelf.shelf.id,
                      onSelected: buildingConstellationId == null
                          ? (_) => onConstellation(shelf)
                          : null,
                    ),
                ],
              },
            ]),
            if (filter.isActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: OutlinedButton(
                  onPressed: () => onChanged(UniverseFilter.none),
                  child: Text(l10n?.universeFilterClear ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The accessible view of the system in focus: its star first, then every
/// planet the filter keeps, in orbit order, each one openable, travelable
/// and with the card's actions in a menu.
class _UniverseList extends StatelessWidget {
  final MovieUniverseExploring state;
  final ValueChanged<Movie> onOpenMovie;
  final ValueChanged<Movie> onTravel;
  final VoidCallback onBackToOrigin;
  final VoidCallback onShareRoute;
  final VoidCallback onClearFilter;
  final ValueChanged<Movie> onAddToWatchlist;
  final ValueChanged<Movie> onAddToShelves;

  const _UniverseList({
    required this.state,
    required this.onOpenMovie,
    required this.onTravel,
    required this.onBackToOrigin,
    required this.onShareRoute,
    required this.onClearFilter,
    required this.onAddToWatchlist,
    required this.onAddToShelves,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final system = state.currentSystem;
    final travelingTo = state.travelingTo;
    final planets = state.matchingPlanets;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (system.hops > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _HopsBar(
              hops: system.hops,
              onBackToOrigin: onBackToOrigin,
              onShareRoute: onShareRoute,
            ),
          ),
        if (state.filter.isActive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _FilterBar(
              filter: state.filter,
              matching: planets.length,
              total: system.planets.length,
              onClear: onClearFilter,
            ),
          ),
        ListTile(
          leading: _Poster(movie: system.star, width: 40),
          title: Text(system.star.displayTitle),
          subtitle: Text(l10n?.universeCenterLabel ?? ''),
          onTap: () => onOpenMovie(system.star),
        ),
        const Divider(),
        if (planets.isEmpty && state.filter.isActive)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n?.universeFilterNoMatch ?? '',
              textAlign: TextAlign.center,
            ),
          ),
        for (final planet in planets)
          ListTile(
            leading: _Poster(movie: planet.movie, width: 40),
            title: Text(planet.movie.displayTitle),
            subtitle: _PlanetSubtitle(planet: planet),
            isThreeLine: _inCommon(context, planet.similar) != null,
            onTap: () => onOpenMovie(planet.movie),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<VoidCallback>(
                  tooltip: l10n?.universeMoreActions(planet.movie.displayTitle),
                  onSelected: (action) => action(),
                  itemBuilder: (_) => [
                    if (planet.movie.me?.status == null)
                      PopupMenuItem(
                        value: () => onAddToWatchlist(planet.movie),
                        child: Text(l10n?.universeWantToWatch ?? ''),
                      ),
                    PopupMenuItem(
                      value: () => onAddToShelves(planet.movie),
                      child: Text(l10n?.universeAddToShelf ?? ''),
                    ),
                  ],
                ),
                if (travelingTo?.id == planet.movie.id)
                  const SizedBox.square(
                    dimension: 48,
                    child: Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  IconButton(
                    tooltip: l10n?.universeTravelTo(planet.movie.displayTitle),
                    icon: const Icon(Icons.rocket_launch_outlined),
                    onPressed: travelingTo == null
                        ? () => onTravel(planet.movie)
                        : null,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The year, the viewer's state and what the planet shares with its star.
class _PlanetSubtitle extends StatelessWidget {
  final OrbitingPlanet planet;

  const _PlanetSubtitle({required this.planet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final year = planet.movie.year;
    final status = planet.movie.me?.status;
    final inCommon = _inCommon(context, planet.similar);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (year != null || status != null)
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (year != null) Text(year),
              if (status != null) _StatusLabel(status: status),
            ],
          ),
        if (inCommon != null)
          Text(
            l10n?.universeInCommon(inCommon) ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  final Movie movie;
  final double width;

  const _Poster({required this.movie, required this.width});

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: ExcludeSemantics(child: Icon(Icons.movie))),
    );
    return ClipRRect(
      borderRadius: MuuvieRadius.smallAll,
      child: SizedBox(
        width: width,
        height: width * 1.5,
        child: movie.posterPath.isEmpty
            ? placeholder
            : CachedNetworkImage(
                imageUrl: TmdbImageUrl.buildPosterSmall(movie.posterPath),
                fit: BoxFit.cover,
                placeholder: (_, _) => placeholder,
                errorWidget: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
