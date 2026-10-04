import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';

import 'package:search/most_popular/most_popular_bloc.dart';
import 'package:search/most_popular/most_popular_state.dart';

class MostPopularScreen extends StatelessWidget {
  final MostPopularCubit cubit;
  final void Function(int movieId, String movieTitle) onMovieTap;


  const MostPopularScreen({
    super.key,
    required this.cubit,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<MostPopularCubit, MostPopularState>(
          builder: (context, state) => switch (state) {
            MostPopularLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            MostPopularError(:final message) => MuuvieEmptyState(
                title: l10n?.emptyStateErrorTitle ?? '',
                message: message,
              ),
            MostPopularSuccess() => PagingListener(
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
                      onTap: () => onMovieTap(movie.id, movie.title),
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
      ),
    );
  }
}
