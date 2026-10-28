import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:profile/profile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:profile_ui/member/highlights/highlights_bloc.dart';
import 'package:profile_ui/profile_router.dart';

/// The Destaques tab (F5.4): top 4, featured shelf, featured locadora and
/// soundtrack, in the order the owner chose.
class HighlightsTab extends StatefulWidget {
  /// The owner, or `me` for the current user.
  final String userId;

  /// Opens the editor; null on other profiles.
  final Future<bool?> Function()? onEdit;

  /// Also called by pull to refresh, e.g. to reload the profile counters.
  final Future<void> Function()? onRefresh;

  const HighlightsTab({
    super.key,
    required this.userId,
    this.onEdit,
    this.onRefresh,
  });

  @override
  State<HighlightsTab> createState() => _HighlightsTabState();
}

class _HighlightsTabState extends State<HighlightsTab> {
  late final HighlightsCubit _cubit = HighlightsCubit(
    userId: widget.userId,
    getHighlights: GetIt.I<GetProfileHighlights>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _edit() async {
    final saved = await widget.onEdit?.call();
    if (saved ?? false) _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canEdit = widget.onEdit != null;

    return BlocBuilder<HighlightsCubit, HighlightsState>(
      bloc: _cubit,
      builder: (context, state) => switch (state) {
        HighlightsLoading() => const Center(child: CircularProgressIndicator()),
        HighlightsError(:final message) => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: message,
          action: _cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        // A list, so the empty state scrolls instead of overflowing when the
        // tab is short (keyboard open, header expanded).
        HighlightsSuccess(:final highlights) when highlights.isEmpty =>
          ListView(
            padding: const EdgeInsets.only(top: 32),
            children: [
              MuuvieEmptyState(
                illustration: MuuvieIllustration.movies,
                title: canEdit
                    ? l10n?.highlightsEmptyOwnTitle ?? ''
                    : l10n?.emptyStateNoItemsTitle ?? '',
                message: canEdit
                    ? l10n?.highlightsEmptyOwnMessage ?? ''
                    : l10n?.highlightsEmptyOther ?? '',
                action: canEdit ? _edit : null,
                actionLabel: canEdit ? l10n?.highlightsEdit : null,
              ),
            ],
          ),
        HighlightsSuccess(:final highlights) => RefreshIndicator(
          onRefresh: () => Future.wait([
            _cubit.load(),
            if (widget.onRefresh != null) widget.onRefresh!(),
          ]),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (canEdit)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton.icon(
                      onPressed: _edit,
                      icon: const Icon(Icons.tune),
                      label: Text(l10n?.highlightsEdit ?? ''),
                    ),
                  ),
                ),
              for (final highlight in highlights)
                _HighlightSection(highlight: highlight),
            ],
          ),
        ),
      },
    );
  }
}

class _HighlightSection extends StatelessWidget {
  final ProfileHighlight highlight;

  const _HighlightSection({required this.highlight});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final shelf = highlight.shelf;
    final locadora = highlight.locadora;
    final soundtrack = highlight.soundtrackUrl;
    final service =
        SoundtrackService.of(soundtrack) ?? SoundtrackService.spotify;

    final content = switch (highlight.type) {
      HighlightType.top4 => _TopMovies(movies: highlight.movies),
      HighlightType.shelf when shelf != null => HighlightCollectionCard(
        title: l10n?.shelfName(shelf.systemType, shelf.name) ?? shelf.name,
        subtitle: l10n?.shelfWatchedOfTotal(
          shelf.totalWatched,
          shelf.totalMovies,
        ),
        posterPaths: shelf.posterPaths,
        onTap: () => context.router.push(
          ShelfDetailRoute(
            shelfId: shelf.id,
            shelfName: shelf.name,
            shelfColor: shelf.color,
          ),
        ),
      ),
      HighlightType.locadora when locadora != null => HighlightCollectionCard(
        title: locadora.name,
        subtitle: l10n?.locadoraProgress(
          locadora.totalWatched,
          locadora.totalMovies,
        ),
        posterPaths: locadora.posterPaths,
        onTap: () => context.router.push(
          LocadoraDetailRoute(
            locadoraId: locadora.id,
            locadoraName: locadora.name,
            onOpenShelf: (context, shelf) => context.router.push(
              ShelfDetailRoute(
                shelfId: shelf.id,
                shelfName: shelf.name,
                shelfColor: shelf.color,
              ),
            ),
          ),
        ),
      ),
      HighlightType.soundtrack when soundtrack != null => Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(
            service == SoundtrackService.youtubeMusic
                ? Icons.play_circle_outline
                : Icons.music_note,
          ),
          title: Text(l10n?.highlightSoundtrackOpen(service.name) ?? ''),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(
            Uri.parse(soundtrack),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ),
      _ => null,
    };
    if (content == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n?.highlightTitle(highlight.type.wireValue) ?? '',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

class _TopMovies extends StatelessWidget {
  final List<HighlightMovie> movies;

  const _TopMovies({required this.movies});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < 4; index++) ...[
        if (index > 0) const SizedBox(width: 8),
        Expanded(
          child: index < movies.length
              ? _Poster(movie: movies[index])
              : const AspectRatio(aspectRatio: 2 / 3),
        ),
      ],
    ],
  );
}

class _Poster extends StatelessWidget {
  final HighlightMovie movie;

  const _Poster({required this.movie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = movie.posterPath;
    final placeholder = Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      child: Text(
        movie.title,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );

    return Semantics(
      label: movie.title,
      button: true,
      child: InkWell(
        borderRadius: MuuvieRadius.smallAll,
        onTap: () => context.router.push(
          MovieDetailRoute(movieId: movie.movieId, movieTitle: movie.title),
        ),
        child: ClipRRect(
          borderRadius: MuuvieRadius.smallAll,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: path == null
                ? placeholder
                : CachedNetworkImage(
                    imageUrl: TmdbImageUrl.buildPosterMedium(path),
                    fit: BoxFit.cover,
                    placeholder: (_, _) => placeholder,
                    errorWidget: (_, _, _) => placeholder,
                  ),
          ),
        ),
      ),
    );
  }
}

/// A shelf or locadora card with a row of posters, used by the highlights and
/// by the discovery hub.
class HighlightCollectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> posterPaths;
  final VoidCallback onTap;

  const HighlightCollectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.posterPaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final label = subtitle;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: MuuvieRadius.largeAll,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (label != null)
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var index = 0; index < 4; index++) ...[
                    if (index > 0) const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: MuuvieRadius.smallAll,
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: index < posterPaths.length
                              ? CachedNetworkImage(
                                  imageUrl: TmdbImageUrl.buildPosterSmall(
                                    posterPaths[index],
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => ColoredBox(
                                    color: colorScheme.surfaceContainerHighest,
                                  ),
                                )
                              : ColoredBox(
                                  color: colorScheme.surfaceContainerHighest,
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
