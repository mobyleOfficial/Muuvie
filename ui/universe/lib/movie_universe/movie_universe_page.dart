import 'package:auth/auth.dart' show IsUserAuthenticated;
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:shelves/shelves.dart' show AddMovieToWatchlist;
import 'package:shelves_ui/shelves_router.dart';
import 'package:watch_logs/watch_logs.dart' show GetMovieWatchState;
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
    addMovieToWatchlist: GetIt.I<AddMovieToWatchlist>(),
    getMovieWatchState: GetIt.I<GetMovieWatchState>(),
    origin: Movie(
      id: widget.movieId,
      title: widget.movieTitle,
      posterPath: widget.posterPath,
    ),
  );
  bool _loadStarted = false;

  /// Android reports a screen reader a frame or two after the app starts,
  /// so the first read can miss it: every later change is listened to.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenReader = MediaQuery.accessibleNavigationOf(context);
    if (!_loadStarted) {
      _loadStarted = true;
      _cubit.load(startAsList: screenReader);
    } else if (screenReader) {
      _cubit.useScreenReader();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Asks for a login when there is none. A login made here means every
  /// planet was loaded without the viewer's states, so they are refreshed.
  Future<bool> _ensureLoggedIn() async {
    final before = await GetIt.I<IsUserAuthenticated>()();
    final wasLoggedIn = before is Success<bool> && before.data;
    if (!mounted) return false;
    if (!await AuthGate.check(context) || !mounted) return false;
    if (!wasLoggedIn) _cubit.refreshStates();
    return true;
  }

  /// "Quero ver" asks for a login first; the snackbar says how it went.
  Future<void> _addToWatchlist(Movie movie) async {
    if (!await _ensureLoggedIn()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = await _cubit.addToWatchlist(movie);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (added
                  ? l10n?.universeAddedToWatchlist(movie.displayTitle)
                  : l10n?.universeWantToWatchError) ??
              '',
        ),
      ),
    );
  }

  /// The shelves picked may include Já assisti or Quero ver, which the
  /// planet shows: its state is asked again once the screen closes.
  Future<void> _addToShelves(Movie movie) async {
    if (!await _ensureLoggedIn()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final count = await context.router.root.push<int>(
      AddToShelvesRoute(movieId: movie.id, movieTitle: movie.displayTitle),
    );
    if (count == null) return;
    _cubit.refreshMovieState(movie.id);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n?.addToShelvesSaved(count) ?? '')),
    );
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
          onAddToWatchlist: _addToWatchlist,
          onAddToShelves: _addToShelves,
        ),
      );
}
