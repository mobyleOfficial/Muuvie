import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_router.dart';
import 'package:movies_ui/tabs/lists/movies_list_tile.dart';

import 'package:profile_ui/profile_router.dart';
import 'package:profile_ui/tabs/lists/user_movie_lists_bloc.dart';
import 'package:profile_ui/tabs/lists/user_movie_lists_state.dart';

class UserMovieListsScreen extends StatelessWidget {
  final UserMovieListsCubit cubit;

  const UserMovieListsScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<UserMovieListsCubit, UserMovieListsState>(
        builder: (context, state) => switch (state) {
          UserMovieListsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          UserMovieListsError(:final message) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
            ),
          UserMovieListsSuccess() => Stack(
              children: [
                PagingListener(
                  controller: cubit.pagingController,
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
                          posterPaths:
                              movieList.info?.posterPaths ?? const [],
                          onTap: () => context.router.push(
                            MovieListDetailRoute(
                              listId: movieList.id,
                              listName: movieList.name,
                              posterPaths:
                                  movieList.info?.posterPaths ?? const [],
                            ),
                          ),
                        ),
                      ),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      firstPageErrorIndicatorBuilder: (_) =>
                          MuuvieEmptyState(
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
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'createListFab',
                    onPressed: () async {
                      final result = await context.router.root
                          .push<bool>(const CreateListRoute());
                      if (result == true) {
                        cubit.pagingController.refresh();
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }
}
