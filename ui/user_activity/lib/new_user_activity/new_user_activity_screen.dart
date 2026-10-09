import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reviews/review_creation/review_creation_router.dart';
import 'package:movies/movies.dart';
import 'package:user_activity/model/tab_items.dart';
import 'package:user_activity/new_user_activity/new_user_activity_bloc.dart';
import 'package:user_activity/new_user_activity/new_user_activity_state.dart';

class NewUserActivityScreen extends StatefulWidget {
  final NewUserActivityCubit cubit;

  const NewUserActivityScreen({super.key, required this.cubit});

  @override
  State<NewUserActivityScreen> createState() => _NewUserActivityScreenState();
}

class _NewUserActivityScreenState extends State<NewUserActivityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<ActivityItem> _buildItems(
    AppLocalizations? l10n,
    List<MovieReviewDraft> drafts,
    List<RecentSearch> recentSearches,
  ) => [
    if (drafts.isNotEmpty) ...[
      SectionHeader(l10n?.newUserActivityDraftsSection ?? ''),
      ...drafts.map(
        (draft) => DraftItem(
          title: draft.movieTitle,
          subtitle: draft.reviewTitle.isEmpty
              ? formatTimeAgo(draft.updatedAt)
              : '${draft.reviewTitle} · ${formatTimeAgo(draft.updatedAt)}',
          draft: draft,
        ),
      ),
    ],
    if (recentSearches.isNotEmpty) ...[
      SectionHeader(l10n?.newUserActivityRecentSection ?? ''),
      ...recentSearches.map(
        (search) => SearchItem(
          query: search.query,
          time: formatTimeAgo(search.searchedAt),
        ),
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final searchField = Theme(
      data: Theme.of(context).copyWith(
        colorScheme: colorScheme.copyWith(
          surfaceContainerHighest: Colors.white.withValues(alpha: 0.15),
          onSurface: Colors.white,
          onSurfaceVariant: Colors.white.withValues(alpha: 0.7),
          primary: Colors.white,
        ),
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) => MuuvieEditText(
          controller: _searchController,
          focusNode: _focusNode,
          placeholder: l10n?.searchHint ?? '',
          textInputAction: TextInputAction.search,
          onChanged: widget.cubit.onSearchChanged,
          onSubmitted: widget.cubit.onSearchSubmitted,
          suffixIcon: value.text.isNotEmpty
              ? Tooltip(
                  message: l10n?.clearSearch ?? 'Clear',
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.white.withValues(alpha: 0.7),
                    onPressed: () {
                      _searchController.clear();
                      widget.cubit.onSearchChanged('');
                    },
                  ),
                )
              : null,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MuuvieModalScreen(
        titleWidget: searchField,
        body: BlocProvider.value(
          value: widget.cubit,
          child: BlocBuilder<NewUserActivityCubit, NewUserActivityState>(
            builder: (context, state) => switch (state) {
              NewUserActivityLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              NewUserActivityError() => MuuvieEmptyState(
                title: l10n?.emptyStateErrorTitle ?? '',
                message: state.message,
              ),
              NewUserActivitySearching() => const Center(
                child: CircularProgressIndicator(),
              ),
              NewUserActivitySearchResults() => _SearchResultsList(
                movies: state.movies,
                onMovieSelected: () =>
                    widget.cubit.onSearchSubmitted(_searchController.text),
              ),
              NewUserActivitySuccess() => Builder(
                builder: (context) {
                  final items = _buildItems(
                    l10n,
                    state.drafts,
                    state.recentSearches,
                  );
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => switch (items[index]) {
                      SectionHeader(:final label) => _SectionHeaderTile(
                        label: label,
                      ),
                      DraftItem(:final title, :final subtitle, :final draft) =>
                        _SwipeToDismissDraft(
                          movieId: draft.movieId,
                          onConfirmDelete: () =>
                              widget.cubit.deleteDraft(draft.movieId),
                          child: _DraftTile(
                            title: title,
                            subtitle: subtitle,
                            onTap: () => context.router.root.push(
                              ReviewCreationRoute(
                                movieId: draft.movieId,
                                movieTitle: draft.movieTitle,
                                posterPath: draft.posterPath,
                                initialDraft: draft,
                              ),
                            ),
                            showSubmit:
                                draft.reviewTitle.isNotEmpty &&
                                draft.rating > 0 &&
                                draft.reviewBody.isNotEmpty &&
                                draft.tags.isNotEmpty,
                          ),
                        ),
                      SearchItem(:final query, :final time) => _SearchTile(
                        query: query,
                        time: time,
                        onTap: () {
                          _searchController.text = query;
                          widget.cubit.onSearchChanged(query);
                        },
                      ),
                    },
                  );
                },
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final List<Movie> movies;
  final VoidCallback? onMovieSelected;

  const _SearchResultsList({required this.movies, this.onMovieSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (movies.isEmpty) {
      return Center(
        child: Text(
          l10n?.noResults ?? '',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movies.length,
      separatorBuilder: (_, _) =>
          Divider(indent: 72, height: 1, color: colorScheme.outlineVariant),
      itemBuilder: (context, index) =>
          _MovieResultTile(movie: movies[index], onTap: onMovieSelected),
    );
  }
}

class _MovieResultTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const _MovieResultTile({required this.movie, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '${movie.title}, ${movie.info?.releaseDate ?? ''}',
      button: true,
      child: InkWell(
        onTap: () {
          onTap?.call();
          context.router.root.push(
            ReviewCreationRoute(
              movieId: movie.id,
              movieTitle: movie.title,
              posterPath: movie.posterPath,
            ),
          );
        },
        child: ExcludeSemantics(
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
                            imageUrl: TmdbImageUrl.buildPosterSmall(
                              movie.posterPath,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.movie,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.movie,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                          color: colorScheme.onSurface,
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
                if ((movie.info?.voteAverage ?? 0) > 0) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        movie.info!.voteAverage.toStringAsFixed(1),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeToDismissDraft extends StatelessWidget {
  final int movieId;
  final VoidCallback onConfirmDelete;
  final Widget child;

  const _SwipeToDismissDraft({
    required this.movieId,
    required this.onConfirmDelete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey('draft_$movieId'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        var confirmed = false;
        await MuuvieDialog.show(
          context: context,
          title: l10n?.deleteDraftTitle ?? '',
          content: l10n?.deleteDraftContent ?? '',
          confirmText: l10n?.delete ?? '',
          cancelText: l10n?.cancel ?? '',
          onConfirm: () => confirmed = true,
        );
        return confirmed;
      },
      onDismissed: (_) => onConfirmDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: colorScheme.error,
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      child: child,
    );
  }
}

class _SectionHeaderTile extends StatelessWidget {
  final String label;

  const _SectionHeaderTile({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showSubmit;

  const _DraftTile({
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showSubmit = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$title, $subtitle',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
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
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSubmit)
                ExcludeSemantics(
                  child: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  final String query;
  final String time;
  final VoidCallback? onTap;

  const _SearchTile({required this.query, required this.time, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$query, $time',
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  query,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Text(
                  time,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
