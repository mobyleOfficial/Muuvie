import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:universe_ui/movie_universe/movie_universe_bloc.dart';
import 'package:universe_ui/movie_universe/movie_universe_screen.dart';
import 'package:universe_ui/movie_universe/movie_universe_state.dart';

/// Opened from the "Ações" sheet of the movie detail. [movieId] is the
/// database id; the title and poster draw the star while the planets load.
@RoutePage()
class MovieUniversePage extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String posterPath;

  const MovieUniversePage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.posterPath = '',
  });

  @override
  State<MovieUniversePage> createState() => _MovieUniversePageState();
}

class _MovieUniversePageState extends State<MovieUniversePage> {
  late final MovieUniverseCubit _cubit = MovieUniverseCubit(
    getSimilarMovies: GetIt.I<GetSimilarMovies>(),
    origin: Movie(
      id: widget.movieId,
      title: widget.movieTitle,
      posterPath: widget.posterPath,
    ),
  );
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) return;
    _loadStarted = true;
    _cubit.load(startAsList: MediaQuery.accessibleNavigationOf(context));
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<MovieUniverseCubit, MovieUniverseState>(
        bloc: _cubit,
        listenWhen: (_, state) =>
            state is MovieUniverseExploring && state.failedTravel != null,
        listener: (context, state) {
          final failed = (state as MovieUniverseExploring).failedTravel!;
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.universeTravelError(failed.displayTitle) ?? '',
              ),
            ),
          );
        },
        child: MovieUniverseScreen(
          cubit: _cubit,
          onOpenMovie: (movie) => context.router.push(
            MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
          ),
        ),
      );
}
