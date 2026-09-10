import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_router.dart';
import 'package:movies_ui/tabs/lists/movies_list_tile.dart';
import 'package:movies_ui/tabs/lists/movies_lists_bloc.dart';
import 'package:reviews/review_details/review_details_router.dart';
import 'package:reviews/reviews_list/reviews_bloc.dart';
import 'package:search/search_bloc.dart';
import 'package:search/search_router.dart';
import 'package:search/search_state.dart';

class SearchScreen extends StatefulWidget {
  final SearchCubit cubit;

  const SearchScreen({super.key, required this.cubit});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    _updateSearchVisibility();
  }

  void _onTextChanged() {
    _updateSearchVisibility();
  }

  void _updateSearchVisibility() {
    final hasText = _searchController.text.isNotEmpty;
    final shouldShow = hasText && (_showSearchResults || _focusNode.hasFocus);
    if (shouldShow != _showSearchResults) {
      setState(() => _showSearchResults = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: widget.cubit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: MuuvieEditText(
              controller: _searchController,
              focusNode: _focusNode,
              placeholder: l10n?.searchHint ?? '',
              textInputAction: TextInputAction.search,
              onChanged: widget.cubit.onSearchChanged,
            ),
          ),
          Expanded(
            child: _showSearchResults
                ? _SearchResultsSection(cubit: widget.cubit)
                : _BrowseSection(l10n: l10n, colorScheme: colorScheme, textTheme: textTheme),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsSection extends StatefulWidget {
  final SearchCubit cubit;

  const _SearchResultsSection({required this.cubit});

  @override
  State<_SearchResultsSection> createState() => _SearchResultsSectionState();
}

class _SearchResultsSectionState extends State<_SearchResultsSection> {
  static const _categories = [
    'Movies',
    'Reviews',
    'Lists',
    'Cast & Crew',
    'Stories',
    'Users',
    'Articles',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: _categories.length,
      child: Column(
        children: [
          const MuuvieTabBar(
            isScrollable: true,
            tabs: _categories,
          ),
          Expanded(
            child: TabBarView(
              children: [
                MuuvieKeepAliveTab(
                  child: _MoviesResultsTab(cubit: widget.cubit),
                ),
                const MuuvieKeepAliveTab(child: _ReviewsResultsTab()),
                const MuuvieKeepAliveTab(child: _ListsResultsTab()),
                for (var index = 3; index < _categories.length; index++)
                  MuuvieKeepAliveTab(
                    child: Center(
                      child: Text(
                        '${_categories[index]} coming soon',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
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

class _MoviesResultsTab extends StatelessWidget {
  final SearchCubit cubit;

  const _MoviesResultsTab({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) => switch (state) {
        SearchSearching() => const Center(
            child: CircularProgressIndicator(),
          ),
        SearchResults(:final movies) => movies.isEmpty
            ? Center(
                child: Text(
                  l10n?.noResults ?? '',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: movies.length,
                separatorBuilder: (_, _) => Divider(
                  indent: 72,
                  height: 1,
                  color: colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) => _MovieResultTile(
                  movie: movies[index],
                ),
              ),
        SearchError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
          ),
        SearchIdle() => const SizedBox.shrink(),
      },
    );
  }
}

class _ReviewsResultsTab extends StatefulWidget {
  const _ReviewsResultsTab();

  @override
  State<_ReviewsResultsTab> createState() => _ReviewsResultsTabState();
}

class _ReviewsResultsTabState extends State<_ReviewsResultsTab> {
  late final ReviewsCubit _cubit = ReviewsCubit(
    GetIt.I<GetMovieReviews>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final posterColors = [
      colorScheme.tertiaryContainer,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.surfaceContainerHighest,
    ];

    return BlocProvider.value(
      value: _cubit,
      child: PagingListener(
        controller: _cubit.pagingController,
        builder: (context, pagingState, fetchNextPage) =>
            PagedListView<int, MovieReview>(
          state: pagingState,
          fetchNextPage: fetchNextPage,
          padding: const EdgeInsets.symmetric(vertical: 8),
          builderDelegate: PagedChildBuilderDelegate<MovieReview>(
            itemBuilder: (context, review, index) => Column(
              children: [
                if (index > 0)
                  Divider(
                    indent: 72,
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                _ReviewResultTile(
                  review: review,
                  posterColor: posterColors[index % posterColors.length],
                ),
              ],
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
          ),
        ),
      ),
    );
  }
}

class _ReviewResultTile extends StatelessWidget {
  final MovieReview review;
  final Color posterColor;

  const _ReviewResultTile({
    required this.review,
    required this.posterColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.router.push(
        ReviewDetailsRoute(reviewId: review.id, movieTitle: review.title),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 64,
              decoration: BoxDecoration(
                color: posterColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.date,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (starIndex) {
                      final isFilled = starIndex < review.rating.floor();
                      final isHalf = !isFilled && starIndex < review.rating;
                      return Icon(
                        isHalf
                            ? Icons.star_half
                            : (isFilled ? Icons.star : Icons.star_border),
                        size: 14,
                        color: colorScheme.onTertiaryContainer,
                      );
                    }),
                  ),
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
    );
  }
}

class _ListsResultsTab extends StatefulWidget {
  const _ListsResultsTab();

  @override
  State<_ListsResultsTab> createState() => _ListsResultsTabState();
}

class _ListsResultsTabState extends State<_ListsResultsTab> {
  late final MoviesListsCubit _cubit = MoviesListsCubit(
    GetIt.I<GetMovieLists>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: PagingListener(
        controller: _cubit.pagingController,
        builder: (context, pagingState, fetchNextPage) =>
            PagedListView<int, MovieList>(
          state: pagingState,
          fetchNextPage: fetchNextPage,
          padding: const EdgeInsets.all(16),
          builderDelegate: PagedChildBuilderDelegate<MovieList>(
            itemBuilder: (context, movieList, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MoviesListTile(
                title: movieList.name,
                creator: movieList.creator,
                description: movieList.description,
                posterPaths: movieList.info?.posterPaths ?? const [],
                onTap: () => context.router.push(
                  MovieListDetailRoute(
                    listId: movieList.id,
                    listName: movieList.name,
                    posterPaths: movieList.info?.posterPaths ?? const [],
                  ),
                ),
              ),
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
          ),
        ),
      ),
    );
  }
}

class _MovieResultTile extends StatelessWidget {
  final Movie movie;

  const _MovieResultTile({required this.movie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.router.push(
        MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
      ),
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
                        imageUrl: TmdbImageUrl.buildPosterSmall(movie.posterPath),
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
    );
  }
}

class _BrowseSection extends StatelessWidget {
  final AppLocalizations? l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _BrowseSection({
    required this.l10n,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            l10n?.searchBrowse ?? '',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _BrowseItem(
                icon: Icons.calendar_today_outlined,
                label: l10n?.searchBrowseReleaseDate ?? '',
                onTap: () => context.router.push(
                  const ReleaseDateDecadesRoute(),
                ),
              ),
              _BrowseItem(
                icon: Icons.category_outlined,
                label: l10n?.searchBrowseGenreCountryLanguage ?? '',
                onTap: () => context.router.push(
                  const BrowseCategoriesRoute(),
                ),
              ),
              _BrowseItem(
                icon: Icons.trending_up,
                label: l10n?.searchBrowseMostPopular ?? '',
                onTap: () => context.router.push(
                  const MostPopularRoute(),
                ),
              ),
              _BrowseItem(
                icon: Icons.star_outline,
                label: l10n?.searchBrowseHighestRated ?? '',
                onTap: () => context.router.push(
                  const HighestRatedRoute(),
                ),
              ),
              _BrowseItem(
                icon: Icons.schedule,
                label: l10n?.searchBrowseMostAnticipated ?? '',
                onTap: () => context.router.push(
                  const MostAnticipatedRoute(),
                ),
              ),
              _BrowseItem(
                icon: Icons.list_alt,
                label: l10n?.searchBrowseFeaturedLists ?? '',
                onTap: () => context.router.push(
                  const FeaturedListsRoute(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrowseItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _BrowseItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: ExcludeSemantics(child: Icon(icon, color: colorScheme.onSurface)),
      title: Text(label),
      trailing: ExcludeSemantics(
        child: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      ),
      onTap: onTap ?? () {},
    );
  }
}
