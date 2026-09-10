import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

import 'package:profile_ui/tabs/watchlist/watchlist_bloc.dart';
import 'package:profile_ui/tabs/watchlist/watchlist_state.dart';

class WatchlistScreen extends StatelessWidget {
  final WatchlistCubit cubit;

  const WatchlistScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, state) => switch (state) {
          WatchlistLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          WatchlistError(:final message) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
            ),
          WatchlistSuccess() => PagingListener(
              controller: cubit.pagingController,
              builder: (context, pagingState, fetchNextPage) =>
                  PagedGridView<int, Movie>(
                state: pagingState,
                fetchNextPage: fetchNextPage,
                padding: const EdgeInsets.symmetric(
                  horizontal: muuvieGridPadding,
                  vertical: muuvieGridPadding,
                ),
                gridDelegate: muuvieGridDelegate,
                builderDelegate: PagedChildBuilderDelegate<Movie>(
                  itemBuilder: (context, movie, index) =>
                      MuuvieMoviePosterCard(
                    imageUrl: movie.posterPath.isNotEmpty
                        ? TmdbImageUrl.buildPosterLarge(movie.posterPath)
                        : null,
                    onTap: () => context.router.push(
                      MovieDetailRoute(
                        movieId: movie.id,
                        movieTitle: movie.title,
                        filmowId: movie.filmowId,
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
        },
      ),
    );
  }
}
