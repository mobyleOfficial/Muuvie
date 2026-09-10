import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_screen.dart';

@RoutePage()
class MovieDetailPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String? filmowId;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.filmowId,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieDetailCubit _cubit = MovieDetailCubit(
    GetIt.I<GetMovieDetail>(),
    widget.movieId,
    filmowId: widget.filmowId,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieDetailScreen(cubit: _cubit);
}