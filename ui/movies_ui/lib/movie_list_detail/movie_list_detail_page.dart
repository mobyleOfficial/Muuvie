import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_bloc.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_screen.dart';

@RoutePage()
class MovieListDetailPage extends StatefulWidget {
  final int listId;
  final String listName;
  final List<String> posterPaths;

  const MovieListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
    required this.posterPaths,
  });

  @override
  State<MovieListDetailPage> createState() => _MovieListDetailPageState();
}

class _MovieListDetailPageState extends State<MovieListDetailPage> {
  late final MovieListDetailCubit _cubit = MovieListDetailCubit(
    GetIt.I<GetMovieListDetail>(),
    GetIt.I<DeleteMovieList>(),
    GetIt.I<AddMovieToList>(),
    GetIt.I<RemoveMovieFromList>(),
    GetIt.I<SearchMovies>(),
    widget.listId,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieListDetailScreen(
        cubit: _cubit,
        posterPaths: widget.posterPaths,
        onMovieTap: (movieId, movieTitle) => context.router.push(
          MovieDetailRoute(movieId: movieId, movieTitle: movieTitle),
        ),
      );
}