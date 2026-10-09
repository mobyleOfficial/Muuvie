import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_bloc.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_state.dart';

class MovieListDetailScreen extends StatefulWidget {
  final MovieListDetailCubit cubit;
  final List<String> posterPaths;
  final void Function(int movieId, String movieTitle) onMovieTap;

  const MovieListDetailScreen({
    super.key,
    required this.cubit,
    required this.posterPaths,
    required this.onMovieTap,
  });

  @override
  State<MovieListDetailScreen> createState() => _MovieListDetailScreenState();
}

class _MovieListDetailScreenState extends State<MovieListDetailScreen> {
  late final String? _headerPoster = widget.posterPaths.isNotEmpty
      ? widget.posterPaths[Random().nextInt(widget.posterPaths.length)]
      : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: widget.cubit,
      child: BlocListener<MovieListDetailCubit, MovieListDetailState>(
        listener: (context, state) {
          if (state is MovieListDetailDeleted) {
            context.router.maybePop(true);
          }
        },
        child: BlocBuilder<MovieListDetailCubit, MovieListDetailState>(
          builder: (context, state) => switch (state) {
            MovieListDetailLoading() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            MovieListDetailError(:final message) => Scaffold(
                body: MuuvieEmptyState(
                  title: l10n?.emptyStateErrorTitle ?? '',
                  message: message,
                  action: widget.cubit.reload,
                  actionLabel: l10n?.emptyStateRetry ?? '',
                ),
              ),
            MovieListDetailDeleted() => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            MovieListDetailSuccess() => _Content(
                state: state,
                cubit: widget.cubit,
                headerPoster: _headerPoster,
                onMovieTap: widget.onMovieTap,
              ),
          },
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final MovieListDetailSuccess state;
  final MovieListDetailCubit cubit;
  final String? headerPoster;
  final void Function(int movieId, String movieTitle) onMovieTap;

  const _Content({
    required this.state,
    required this.cubit,
    required this.headerPoster,
    required this.onMovieTap,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = widget.state.detail;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          MuuvieTabBar(tabs: [
            l10n?.movieListDetailMoviesTab(detail.info?.totalMovies ?? 0) ?? '',
            l10n?.movieListDetailCommentsTab(detail.info?.commentsCount ?? 0) ?? '',
          ]),
          Expanded(
            child: TabBarView(
              children: [
                _MoviesTab(
                  state: widget.state,
                  cubit: widget.cubit,
                  headerPoster: widget.headerPoster,
                  onMovieTap: widget.onMovieTap,
                ),
                Center(
                  child: Text(
                    l10n?.movieListDetailCommentsPlaceholder ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoviesTab extends StatefulWidget {
  final MovieListDetailSuccess state;
  final MovieListDetailCubit cubit;
  final String? headerPoster;
  final void Function(int movieId, String movieTitle) onMovieTap;

  const _MoviesTab({
    required this.state,
    required this.cubit,
    required this.headerPoster,
    required this.onMovieTap,
  });

  @override
  State<_MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends State<_MoviesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteDialog() async {
    final l10n = AppLocalizations.of(context);
    var confirmed = false;
    await MuuvieDialog.show(
      context: context,
      title: 'Delete List',
      content:
          'Are you sure you want to delete this list? This action cannot be undone.',
      confirmText: l10n?.delete ?? 'Delete',
      cancelText: l10n?.cancel ?? 'Cancel',
      onConfirm: () => confirmed = true,
    );

    if (confirmed && mounted) {
      widget.cubit.deleteList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.state.isEditing;

    return PagingListener(
      controller: widget.cubit.pagingController,
      builder: (context, pagingState, fetchNextPage) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              detail: widget.state.detail,
              headerPoster: widget.headerPoster,
              isLiked: widget.state.isLiked,
              likesCount: widget.state.likesCount,
              isEditing: isEditing,
              onToggleLike: widget.cubit.toggleLike,
              onToggleEdit: widget.cubit.toggleEditMode,
              onDelete: _showDeleteDialog,
            ),
          ),
          if (isEditing) ...[
            // Add movies search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADD MOVIES',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, _) => MuuvieEditText(
                        controller: _searchController,
                        placeholder: 'Search movies to add...',
                        textInputAction: TextInputAction.search,
                        onChanged: widget.cubit.onSearchChanged,
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.cubit.onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search results
            if (widget.state.isSearching)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (widget.state.searchResults.isNotEmpty)
              SliverList.separated(
                itemCount: widget.state.searchResults.length,
                separatorBuilder: (_, _) => Divider(
                  indent: 72,
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final movie = widget.state.searchResults[index];
                  final allMovies = pagingState.pages
                          ?.expand((page) => page)
                          .toList() ??
                      [];
                  final isAlreadyInList =
                      allMovies.any((m) => m.id == movie.id);
                  return _SearchResultTile(
                    movie: movie,
                    isSelected: isAlreadyInList,
                    onTap: isAlreadyInList
                        ? null
                        : () => widget.cubit.addMovie(movie),
                  );
                },
              ),
            const SliverToBoxAdapter(
              child: Divider(height: 24),
            ),
          ],
          SliverToBoxAdapter(
            child: _ViewModeToggle(
              isGridView: widget.state.isGridView,
              onToggle: widget.cubit.toggleViewMode,
            ),
          ),
          if (widget.state.isGridView)
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: muuvieGridPadding,
              ),
              sliver: PagedSliverGrid<int, Movie>(
                state: pagingState,
                fetchNextPage: fetchNextPage,
                gridDelegate: muuvieGridDelegate,
                builderDelegate: PagedChildBuilderDelegate<Movie>(
                  itemBuilder: (context, movie, index) => _MovieGridItem(
                    movie: movie,
                    index: index,
                    isEditing: isEditing,
                    onTap: () => widget.onMovieTap(movie.id, movie.title),
                    onRemove: isEditing
                        ? () => widget.cubit.removeMovie(movie.id)
                        : null,
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  firstPageErrorIndicatorBuilder: (_) => MuuvieEmptyState(
                    title: l10n?.emptyStateErrorTitle ?? '',
                    message: l10n?.emptyStateErrorMessage ?? '',
                    action: fetchNextPage,
                    actionLabel: l10n?.emptyStateRetry ?? '',
                  ),
                  noItemsFoundIndicatorBuilder: (_) => MuuvieEmptyState(
                    title: l10n?.emptyStateNoItemsTitle ?? '',
                    message: l10n?.emptyStateNoItemsMessage ?? '',
                  ),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            )
          else
            PagedSliverList<int, Movie>(
              state: pagingState,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<Movie>(
                itemBuilder: (context, movie, index) => _MovieListItem(
                  movie: movie,
                  index: index,
                  isEditing: isEditing,
                  onTap: () => widget.onMovieTap(movie.id, movie.title),
                  onRemove: isEditing
                      ? () => widget.cubit.removeMovie(movie.id)
                      : null,
                ),
                firstPageProgressIndicatorBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                firstPageErrorIndicatorBuilder: (_) => MuuvieEmptyState(
                  title: l10n?.emptyStateErrorTitle ?? '',
                  message: l10n?.emptyStateErrorMessage ?? '',
                  action: fetchNextPage,
                  actionLabel: l10n?.emptyStateRetry ?? '',
                ),
                noItemsFoundIndicatorBuilder: (_) => MuuvieEmptyState(
                  title: l10n?.emptyStateNoItemsTitle ?? '',
                  message: l10n?.emptyStateNoItemsMessage ?? '',
                ),
                newPageProgressIndicatorBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MovieGridItem extends StatelessWidget {
  final Movie movie;
  final int index;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _MovieGridItem({
    required this.movie,
    required this.index,
    this.isEditing = false,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '${index + 1}. ${movie.title}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.expand(
                  child: movie.posterPath.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: TmdbImageUrl.buildPosterLarge(movie.posterPath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(child: Icon(Icons.movie)),
                        ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isEditing && onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
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

class _MovieListItem extends StatelessWidget {
  final Movie movie;
  final int index;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  static const _posterWidth = 50.0;
  static const _posterHeight = 75.0;

  const _MovieListItem({
    required this.movie,
    required this.index,
    this.isEditing = false,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '${index + 1}. ${movie.title}',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (isEditing && onRemove != null)
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.remove_circle,
                      color: colorScheme.error,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  )
                else
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${index + 1}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: _posterWidth,
                    height: _posterHeight,
                    child: movie.posterPath.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: TmdbImageUrl.buildPosterLarge(movie.posterPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(child: Icon(Icons.movie)),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        movie.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (movie.info?.releaseDate.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          movie.info!.releaseDate,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MovieList detail;
  final String? headerPoster;
  final bool isLiked;
  final int likesCount;
  final bool isEditing;
  final VoidCallback onToggleLike;
  final VoidCallback onToggleEdit;
  final VoidCallback onDelete;

  const _Header({
    required this.detail,
    required this.headerPoster,
    required this.isLiked,
    required this.likesCount,
    required this.isEditing,
    required this.onToggleLike,
    required this.onToggleEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerPoster != null)
          CachedNetworkImage(
            imageUrl: TmdbImageUrl.buildBackdrop(headerPoster!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              height: 200,
              color: colorScheme.surfaceContainerHighest,
            ),
            errorWidget: (_, _, _) => Container(
              height: 200,
              color: colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.movie, size: 48)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                detail.creator,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (detail.info?.tags.isNotEmpty ?? false) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.info!.tags
                      .map((tag) => MuuvieTag(label: tag))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  IconButton(
                    onPressed: onToggleLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$likesCount',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleEdit,
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      color: isEditing
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    tooltip: isEditing ? 'Done editing' : 'Edit list',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: colorScheme.error,
                    ),
                    tooltip: 'Delete list',
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggle;

  const _ViewModeToggle({
    required this.isGridView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: isGridView
                ? l10n?.movieListDetailShowListView
                : l10n?.movieListDetailShowGridView,
            child: IconButton(
              onPressed: onToggle,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isGridView ? Icons.view_list : Icons.grid_view,
                  key: ValueKey(isGridView),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SearchResultTile({
    required this.movie,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 64,
                child: movie.posterPath.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl:
                            TmdbImageUrl.buildPosterSmall(movie.posterPath),
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                            color: colorScheme.surfaceContainerHighest),
                        errorWidget: (_, _, _) => Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.movie,
                              size: 20,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.movie,
                            size: 20, color: colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.info?.releaseDate.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      movie.info!.releaseDate.length >= 4
                          ? movie.info!.releaseDate.substring(0, 4)
                          : movie.info!.releaseDate,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 20, color: colorScheme.primary)
            else
              Icon(Icons.add, size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}