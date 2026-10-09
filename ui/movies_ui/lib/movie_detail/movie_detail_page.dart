import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_screen.dart';
import 'package:reviews/review_creation/review_creation_router.dart';

@RoutePage()
class MovieDetailPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieDetailCubit _cubit = MovieDetailCubit(
    GetIt.I<GetMovieDetail>(),
    GetIt.I<LikeMovie>(),
    GetIt.I<UnlikeMovie>(),
    GetIt.I<RateMovie>(),
    GetIt.I<SetMovieStatus>(),
    widget.movieId,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieDetailScreen(
        cubit: _cubit,
        onWriteReview: (movieId, movieTitle, posterPath) {
          context.router.root.push(
            ReviewCreationRoute(
              movieId: movieId,
              movieTitle: movieTitle,
              posterPath: posterPath,
            ),
          );
        },
        onCreateList: (_, __, ___) {
          context.router.root.navigate(
            PageRouteInfo('CreateListRoute'),
          );
        },
      );
}
