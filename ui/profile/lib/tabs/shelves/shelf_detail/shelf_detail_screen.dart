import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_state.dart';

/// A TMDB genre offered by the genre filter.
class GenreOption {
  final int id;
  final String name;

  const GenreOption(this.id, this.name);
}

enum _MovieAction { logSession, remove, moveTo, copyTo }

enum _ShelfMenuAction { reorder, moveAll, copyAll }

class ShelfDetailScreen extends StatelessWidget {
  static final List<int> _decades = [
    for (var year = 2020; year >= 1920; year -= 10) year,
  ];

  final ShelfDetailCubit cubit;
  final Future<Result<List<GenreOption>>> genres;
  final ValueChanged<ShelfMovie> onMovieTap;
  final Future<bool> Function() onAddMovies;
  final Future<Shelf?> Function() onPickTargetShelf;

  /// Opens the session form for the movie (F2.1, "registrar da estante").
  final ValueChanged<ShelfMovie> onLogSession;

  /// Opens the import flow from an empty "Já assisti" (F3.6).
  final VoidCallback onImport;

  /// Opens the profile of the owner of a shelf of someone else (F14.6).
  final ValueChanged<Shelf> onOpenOwner;

  const ShelfDetailScreen({
    super.key,
    required this.cubit,
    required this.genres,
    required this.onMovieTap,
    required this.onAddMovies,
    required this.onPickTargetShelf,
    required this.onLogSession,
    required this.onImport,
    required this.onOpenOwner,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ShelfDetailCubit, ShelfDetailState>(
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: switch (state) {
            ShelfDetailSuccess(:final shelf, isReordering: false)
                when shelf.isSelf =>
              FloatingActionButton(
                tooltip: l10n?.shelfAddMovies,
                backgroundColor: MuuvieColorPicker.fromHex(shelf.color),
                onPressed: () => _report(context, onAddMovies()),
                child: const Icon(Icons.add),
              ),
            _ => null,
          },
          body: switch (state) {
            ShelfDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ShelfDetailError(:final message) => MuuvieEmptyState(
              illustration: MuuvieIllustration.error,
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
              action: cubit.load,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
            ShelfDetailSuccess(isReordering: true) => _ReorderMovies(
              state: state,
              cubit: cubit,
            ),
            ShelfDetailSuccess() => _content(context, state),
          },
        ),
      ),
    );
  }

  bool _offersImport(ShelfDetailSuccess state) =>
      state.shelf.isSelf &&
      state.shelf.systemType == SystemShelfType.watched &&
      state.filter.isEmpty;

  Widget _content(BuildContext context, ShelfDetailSuccess state) {
    final l10n = AppLocalizations.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: cubit.load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(context, state)),
            SliverToBoxAdapter(child: _filters(context, state)),
            if (state.movies.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: MuuvieEmptyState(
                  illustration: MuuvieIllustration.movies,
                  title: l10n?.emptyStateNoItemsTitle ?? '',
                  message: state.filter.isEmpty
                      ? l10n?.emptyStateNoItemsMessage ?? ''
                      : l10n?.shelfEmptyFiltered ?? '',
                  // An empty "Já assisti" offers the Filmow import (F3.6).
                  action: _offersImport(state) ? onImport : null,
                  actionLabel: _offersImport(state)
                      ? l10n?.watchedEmptyImport
                      : null,
                ),
              )
            else if (state.isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: muuvieGridPadding,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate: muuvieGridDelegate,
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) => _PosterTile(
                    movie: state.movies[index],
                    onTap: () => onMovieTap(state.movies[index]),
                    onLongPress: state.shelf.isSelf
                        ? () => _showMovieActions(
                            context,
                            state.shelf,
                            state.movies[index],
                          )
                        : null,
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: state.movies.length,
                itemBuilder: (context, index) => _MovieRow(
                  movie: state.movies[index],
                  onTap: () => onMovieTap(state.movies[index]),
                  onMore: state.shelf.isSelf
                      ? () => _showMovieActions(
                          context,
                          state.shelf,
                          state.movies[index],
                        )
                      : null,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 96),
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ShelfDetailSuccess state) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final shelf = state.shelf;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!shelf.isSelf && shelf.ownerName != null)
            _OwnerRow(
              shelf: shelf,
              onTap: () => onOpenOwner(shelf),
              onToggleSaved: shelf.canBeSaved
                  ? () => _toggleSaved(context)
                  : null,
            ),
          if (shelf.description != null) ...[
            Text(shelf.description!, style: textTheme.bodyMedium),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n?.shelfWatchedOfTotal(
                            shelf.totalWatched,
                            shelf.totalMovies,
                          ) ??
                          '',
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    MuuvieVisibilityChip(visibility: shelf.visibility),
                  ],
                ),
              ),
              if (shelf.isSelf)
                IconButton(
                  tooltip: l10n?.shelfSortBy,
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSort(context, shelf.sortMode),
                ),
              IconButton(
                tooltip: state.isGridView
                    ? l10n?.movieListDetailShowListView
                    : l10n?.movieListDetailShowGridView,
                icon: Icon(
                  state.isGridView ? Icons.view_list : Icons.grid_view,
                ),
                onPressed: cubit.toggleViewMode,
              ),
              if (shelf.isSelf)
                PopupMenuButton<_ShelfMenuAction>(
                  onSelected: (action) => _onShelfMenu(context, action),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _ShelfMenuAction.reorder,
                      child: Text(l10n?.shelfManualOrder ?? ''),
                    ),
                    PopupMenuItem(
                      value: _ShelfMenuAction.moveAll,
                      child: Text(l10n?.shelfMoveAll ?? ''),
                    ),
                    PopupMenuItem(
                      value: _ShelfMenuAction.copyAll,
                      child: Text(l10n?.shelfCopyAll ?? ''),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSaved(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = AppLocalizations.of(context)?.shelfSaveError ?? '';
    if (!await cubit.toggleSaved()) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Widget _filters(BuildContext context, ShelfDetailSuccess state) {
    final l10n = AppLocalizations.of(context);
    final filter = state.filter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          FilterChip(
            label: Text(l10n?.shelfFilterWatched ?? ''),
            selected: filter.watched == true,
            onSelected: (on) => cubit.setFilter(
              filter.copyWith(watched: () => on ? true : null),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(l10n?.shelfFilterNotWatched ?? ''),
            selected: filter.watched == false,
            onSelected: (on) => cubit.setFilter(
              filter.copyWith(watched: () => on ? false : null),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              filter.decade == null
                  ? l10n?.shelfFilterDecade ?? ''
                  : l10n?.shelfFilterDecadeValue(filter.decade!) ?? '',
            ),
            selected: filter.decade != null,
            onSelected: (_) => _pickDecade(context, filter),
          ),
          const SizedBox(width: 8),
          FutureBuilder<Result<List<GenreOption>>>(
            future: genres,
            builder: (context, snapshot) {
              final options = switch (snapshot.data) {
                Success(:final data) => data,
                _ => const <GenreOption>[],
              };
              final selected = options
                  .where((g) => g.id == filter.genreId)
                  .firstOrNull;
              return FilterChip(
                label: Text(selected?.name ?? l10n?.shelfFilterGenre ?? ''),
                selected: filter.genreId != null,
                onSelected: options.isEmpty
                    ? null
                    : (_) => _pickGenre(context, filter, options),
              );
            },
          ),
          if (!filter.isEmpty) ...[
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.close, size: 18),
              label: Text(l10n?.shelfFilterClear ?? ''),
              onPressed: () => cubit.setFilter(ShelfMovieFilter.none),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDecade(
    BuildContext context,
    ShelfMovieFilter filter,
  ) async {
    final l10n = AppLocalizations.of(context);
    final decade = await _pickOne<int>(
      context,
      title: l10n?.shelfFilterDecade ?? '',
      options: {
        for (final decade in _decades)
          decade: l10n?.shelfFilterDecadeValue(decade) ?? '$decade',
      },
      selected: filter.decade,
    );
    if (decade != null) {
      cubit.setFilter(filter.copyWith(decade: () => decade.value));
    }
  }

  Future<void> _pickGenre(
    BuildContext context,
    ShelfMovieFilter filter,
    List<GenreOption> options,
  ) async {
    final genre = await _pickOne<int>(
      context,
      title: AppLocalizations.of(context)?.shelfFilterGenre ?? '',
      options: {for (final genre in options) genre.id: genre.name},
      selected: filter.genreId,
    );
    if (genre != null) {
      cubit.setFilter(filter.copyWith(genreId: () => genre.value));
    }
  }

  /// Single choice with an "Any" option. Returns null when dismissed; `(value: null)` for "Any".
  Future<({T? value})?> _pickOne<T>(
    BuildContext context, {
    required String title,
    required Map<T, String> options,
    required T? selected,
  }) {
    final l10n = AppLocalizations.of(context);
    return MuuvieBottomSheet.show<({T? value})>(
      context: context,
      builder: (sheetContext) => Container(
        color: Theme.of(sheetContext).colorScheme.surface,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              title: Text(l10n?.shelfFilterAny ?? ''),
              trailing: selected == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(sheetContext).pop((value: null)),
            ),
            for (final MapEntry(:key, :value) in options.entries)
              ListTile(
                title: Text(value),
                trailing: key == selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(sheetContext).pop((value: key)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSort(BuildContext context, ShelfSort current) async {
    final choice = await MuuvieBottomSheet.show<(ShelfSort, bool)>(
      context: context,
      builder: (_) => _SortSheet(current: current),
    );
    if (choice == null || !context.mounted) return;
    await _report(context, cubit.sort(choice.$1, applyOnce: choice.$2));
  }

  Future<void> _onShelfMenu(
    BuildContext context,
    _ShelfMenuAction action,
  ) async {
    switch (action) {
      case _ShelfMenuAction.reorder:
        await cubit.startReordering();
      case _ShelfMenuAction.moveAll || _ShelfMenuAction.copyAll:
        final target = await onPickTargetShelf();
        if (target == null || !context.mounted) return;
        final mode = action == _ShelfMenuAction.moveAll
            ? ShelfTransferMode.move
            : ShelfTransferMode.copy;
        await _report(context, cubit.transfer(target.id, mode));
    }
  }

  Future<void> _showMovieActions(
    BuildContext context,
    Shelf shelf,
    ShelfMovie movie,
  ) async {
    final l10n = AppLocalizations.of(context);
    final action = await MuuvieBottomSheet.show<_MovieAction>(
      context: context,
      builder: (sheetContext) => Container(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                movie.title,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_outlined),
              title: Text(l10n?.watchLogAction ?? ''),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_MovieAction.logSession),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text(l10n?.shelfMovieRemove ?? ''),
              onTap: () => Navigator.of(sheetContext).pop(_MovieAction.remove),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: Text(l10n?.shelfMovieMoveTo ?? ''),
              onTap: () => Navigator.of(sheetContext).pop(_MovieAction.moveTo),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l10n?.shelfMovieCopyTo ?? ''),
              onTap: () => Navigator.of(sheetContext).pop(_MovieAction.copyTo),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case _MovieAction.logSession:
        onLogSession(movie);
      case _MovieAction.remove:
        // Leaving "Já assisti" unmarks the movie as watched, so it asks first (F1.2).
        if (shelf.systemType == SystemShelfType.watched &&
            !await _confirmUnmarkWatched(context)) {
          return;
        }
        if (!context.mounted) return;
        await _report(context, cubit.removeMovie(movie.movieId));
      case _MovieAction.moveTo || _MovieAction.copyTo:
        final target = await onPickTargetShelf();
        if (target == null || !context.mounted) return;
        final mode = action == _MovieAction.moveTo
            ? ShelfTransferMode.move
            : ShelfTransferMode.copy;
        await _report(
          context,
          cubit.transfer(target.id, mode, movieIds: [movie.movieId]),
        );
    }
  }

  Future<bool> _confirmUnmarkWatched(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.shelfUnmarkWatchedTitle ?? ''),
        content: Text(l10n?.shelfUnmarkWatchedMessage ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.cancel ?? ''),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.shelfUnmarkWatchedConfirm ?? ''),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Shows a snackbar when an action fails.
  Future<void> _report(BuildContext context, Future<bool> action) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context)?.shelfActionError ?? '';
    if (!await action) messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// The owner of a shelf of someone else, which opens the profile, and the
/// Salvar/Salva toggle (F14.5, F14.6).
class _OwnerRow extends StatelessWidget {
  final Shelf shelf;
  final VoidCallback onTap;
  final VoidCallback? onToggleSaved;

  const _OwnerRow({
    required this.shelf,
    required this.onTap,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = shelf.ownerName ?? '';
    final avatarUrl = shelf.ownerAvatarUrl;
    final onToggleSaved = this.onToggleSaved;

    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              hint: l10n?.shelfOpenOwnerProfile(name),
              excludeSemantics: true,
              label: l10n?.shelfByOwner(name),
              child: InkWell(
                borderRadius: MuuvieRadius.smallAll,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            MuuvieColorPicker.fromHex(shelf.ownerAccentColor) ??
                            colorScheme.surfaceContainerHighest,
                        backgroundImage: avatarUrl == null
                            ? null
                            : CachedNetworkImageProvider(avatarUrl),
                        child: avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n?.shelfByOwner(name) ?? name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (onToggleSaved != null)
            shelf.isSaved
                ? FilledButton.tonalIcon(
                    onPressed: onToggleSaved,
                    icon: const Icon(Icons.bookmark),
                    label: Text(l10n?.shelfSavedLabel ?? ''),
                  )
                : OutlinedButton.icon(
                    onPressed: onToggleSaved,
                    icon: const Icon(Icons.bookmark_border),
                    label: Text(l10n?.shelfSave ?? ''),
                  ),
        ],
      ),
    );
  }
}

class _SortSheet extends StatefulWidget {
  final ShelfSort current;

  const _SortSheet({required this.current});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late ShelfSort _sort = widget.current;
  bool _applyOnce = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              l10n?.shelfSortBy ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: RadioGroup<ShelfSort>(
              groupValue: _sort,
              onChanged: (value) => setState(() => _sort = value ?? _sort),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final sort in ShelfSort.values)
                    RadioListTile<ShelfSort>(
                      value: sort,
                      title: Text(l10n?.shelfSort(sort) ?? sort.wireValue),
                    ),
                ],
              ),
            ),
          ),
          CheckboxListTile(
            value: _applyOnce,
            onChanged: _sort == ShelfSort.manual
                ? null
                : (value) => setState(() => _applyOnce = value ?? false),
            title: Text(l10n?.shelfSortApplyOnce ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: MuuvieButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop((_sort, _applyOnce && _sort != ShelfSort.manual)),
                child: Text(l10n?.shelfSortApply ?? ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderMovies extends StatelessWidget {
  final ShelfDetailSuccess state;
  final ShelfDetailCubit cubit;

  const _ReorderMovies({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: cubit.finishReordering,
            child: Text(l10n?.shelfReorderDone ?? ''),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: state.movies.length,
            onReorderItem: cubit.moveMovie,
            itemBuilder: (context, index) {
              final movie = state.movies[index];
              return ListTile(
                key: ValueKey(movie.movieId),
                leading: _Poster(path: movie.posterPath, width: 36, height: 54),
                title: Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PosterTile extends StatelessWidget {
  final ShelfMovie movie;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PosterTile({
    required this.movie,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: movie.watched
          ? '${movie.title}, ${l10n?.shelfFilterWatched ?? ''}'
          : movie.title,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Poster(path: movie.posterPath),
            if (movie.watched)
              Positioned(
                top: 6,
                right: 6,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: colorScheme.primary,
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovieRow extends StatelessWidget {
  final ShelfMovie movie;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const _MovieRow({required this.movie, required this.onTap, this.onMore});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = [
      if (movie.year != null) '${movie.year}',
      if (movie.director != null) movie.director!,
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      leading: _Poster(path: movie.posterPath, width: 50, height: 75),
      title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, style: textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (movie.watched)
            Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          if (onMore != null)
            IconButton(icon: const Icon(Icons.more_vert), onPressed: onMore),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;

  const _Poster({required this.path, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant),
    );

    return ClipRRect(
      borderRadius: MuuvieRadius.smallAll,
      child: path == null || path!.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: TmdbImageUrl.buildPosterLarge(path!),
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            ),
    );
  }
}
