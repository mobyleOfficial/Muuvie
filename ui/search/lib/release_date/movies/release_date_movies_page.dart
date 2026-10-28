import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

import 'package:search/release_date/movies/release_date_movies_bloc.dart';
import 'package:search/release_date/movies/release_date_movies_screen.dart';

@RoutePage()
class ReleaseDateMoviesPage extends StatefulWidget {
  final String title;
  final int? primaryReleaseYear;
  final String? releaseDateGte;
  final String? releaseDateLte;
  final String? sortBy;
  final String? withGenres;
  final String? withOriginalLanguage;
  final String? withOriginCountry;

  const ReleaseDateMoviesPage({
    super.key,
    required this.title,
    this.primaryReleaseYear,
    this.releaseDateGte,
    this.releaseDateLte,
    this.sortBy,
    this.withGenres,
    this.withOriginalLanguage,
    this.withOriginCountry,
  });

  @override
  State<ReleaseDateMoviesPage> createState() => _ReleaseDateMoviesPageState();
}

class _ReleaseDateMoviesPageState extends State<ReleaseDateMoviesPage> {
  late final ReleaseDateMoviesCubit _cubit = ReleaseDateMoviesCubit(
    GetIt.I<DiscoverMovies>(),
    primaryReleaseYear: widget.primaryReleaseYear,
    releaseDateGte: widget.releaseDateGte,
    releaseDateLte: widget.releaseDateLte,
    sortBy: widget.sortBy,
    withGenres: widget.withGenres,
    withOriginalLanguage: widget.withOriginalLanguage,
    withOriginCountry: widget.withOriginCountry,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ReleaseDateMoviesScreen(
    cubit: _cubit,
    onMovieTap: (movieId, movieTitle) => context.router.push(
      MovieDetailRoute(movieId: movieId, movieTitle: movieTitle),
    ),
  );
}
