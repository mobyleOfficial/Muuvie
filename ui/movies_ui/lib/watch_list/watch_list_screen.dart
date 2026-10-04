import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/watch_list/watch_list_bloc.dart';
import 'package:movies_ui/watch_list/watch_list_state.dart';

class WatchListScreen extends StatefulWidget {
  final GetUserWatchList getUserWatchList;
  final String userId;

  const WatchListScreen({
    super.key,
    required this.getUserWatchList,
    required this.userId,
  });

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  late final WatchListCubit _cubit = WatchListCubit(
    getUserWatchList: widget.getUserWatchList,
    userId: widget.userId,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _cubit,
        child: const _WatchListPaginatedGrid(),
      );
}

class _WatchListPaginatedGrid extends StatelessWidget {
  const _WatchListPaginatedGrid();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WatchListCubit>();

    return PagingListener(
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
          itemBuilder: (context, movie, index) => MuuvieMoviePosterCard(
            imageUrl: movie.posterPath.isNotEmpty
                ? TmdbImageUrl.buildPosterLarge(movie.posterPath)
                : null,
            onTap: () => context.router.push(
              MovieDetailRoute(
                movieId: movie.id,
                movieTitle: movie.title,
              ),
            ),
          ),
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          firstPageErrorIndicatorBuilder: (_) =>
              BlocBuilder<WatchListCubit, WatchListState>(
            builder: (context, state) => Center(
              child: Text(
                state is WatchListError
                    ? state.message
                    : AppLocalizations.of(context)?.unknownError ?? '',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
