import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/favorite_movies/favorite_movies_bloc.dart';
import 'package:movies_ui/favorite_movies/favorite_movies_state.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:profile/profile.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  final GetUserFavoriteMovies getUserFavoriteMovies;
  final String userId;

  const FavoriteMoviesScreen({
    super.key,
    required this.getUserFavoriteMovies,
    required this.userId,
  });

  @override
  State<FavoriteMoviesScreen> createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  late final FavoriteMoviesCubit _cubit = FavoriteMoviesCubit(
    getUserFavoriteMovies: widget.getUserFavoriteMovies,
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
        child: const _FavoriteMoviesPaginatedGrid(),
      );
}

class _FavoriteMoviesPaginatedGrid extends StatelessWidget {
  const _FavoriteMoviesPaginatedGrid();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoriteMoviesCubit>();

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
              BlocBuilder<FavoriteMoviesCubit, FavoriteMoviesState>(
            builder: (context, state) => Center(
              child: Text(
                state is FavoriteMoviesError
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
