import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
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

  const MovieUniverseScreen({
    super.key,
    required this.cubit,
    required this.onOpenMovie,
  });

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
            system: state.currentSystem,
            travelingTo: state.travelingTo,
            onOpenMovie: onOpenMovie,
            onTravel: cubit.travelTo,
            onBackToOrigin: cubit.backToOrigin,
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
                      onSelect: cubit.select,
                      onFocusSystem: cubit.focusSystem,
                    ),
                  ),
                ),
              ),
              if (state.currentSystem.hops > 0)
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: _HopsBar(
                    hops: state.currentSystem.hops,
                    onBackToOrigin: cubit.backToOrigin,
                  ),
                ),
              if (state.selected case final selected?)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: _PlanetCard(
                      movie: selected,
                      traveling: state.travelingTo?.id == selected.id,
                      onOpen: () => onOpenMovie(selected),
                      onTravel: () => cubit.travelTo(selected),
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

  const _HopsBar({required this.hops, required this.onBackToOrigin});

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

/// The card of the selected planet, over the map.
class _PlanetCard extends StatelessWidget {
  final Movie movie;
  final bool traveling;
  final VoidCallback onOpen;
  final VoidCallback onTravel;

  const _PlanetCard({
    required this.movie,
    required this.traveling,
    required this.onOpen,
    required this.onTravel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final year = movie.year;
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
          ],
        ),
      ),
    );
  }
}

/// The accessible view of the system in focus: its star first, then every
/// planet in orbit order, each one openable and travelable.
class _UniverseList extends StatelessWidget {
  final StarSystem system;
  final Movie? travelingTo;
  final ValueChanged<Movie> onOpenMovie;
  final ValueChanged<Movie> onTravel;
  final VoidCallback onBackToOrigin;

  const _UniverseList({
    required this.system,
    required this.travelingTo,
    required this.onOpenMovie,
    required this.onTravel,
    required this.onBackToOrigin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (system.hops > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _HopsBar(hops: system.hops, onBackToOrigin: onBackToOrigin),
          ),
        ListTile(
          leading: _Poster(movie: system.star, width: 40),
          title: Text(system.star.displayTitle),
          subtitle: Text(l10n?.universeCenterLabel ?? ''),
          onTap: () => onOpenMovie(system.star),
        ),
        const Divider(),
        for (final planet in system.planets)
          ListTile(
            leading: _Poster(movie: planet.movie, width: 40),
            title: Text(planet.movie.displayTitle),
            subtitle: planet.movie.year != null
                ? Text(planet.movie.year!)
                : null,
            onTap: () => onOpenMovie(planet.movie),
            trailing: travelingTo?.id == planet.movie.id
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: l10n?.universeTravelTo(planet.movie.displayTitle),
                    icon: const Icon(Icons.rocket_launch_outlined),
                    onPressed: travelingTo == null
                        ? () => onTravel(planet.movie)
                        : null,
                  ),
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
