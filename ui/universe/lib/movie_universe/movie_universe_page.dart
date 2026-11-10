import 'package:auth/auth.dart' show IsUserAuthenticated;
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart' show RecordUniverseVisits;
import 'package:gamification_ui/gamification_router.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shelves/shelves.dart'
    show AddMovieToWatchlist, GetPublicShelvesWithMovie, GetShelfMovies;
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
    recordUniverseVisits: GetIt.I<RecordUniverseVisits>(),
    getPublicShelvesWithMovie: GetIt.I<GetPublicShelvesWithMovie>(),
    getShelfMovies: GetIt.I<GetShelfMovies>(),
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

  /// The route from the origin to the system in focus, as text to share.
  Future<void> _shareRoute() async {
    final route = _cubit.route;
    if (route.length < 2) return;
    final l10n = AppLocalizations.of(context);
    final text = l10n?.universeShareRouteText(
      route.first.displayTitle,
      route.last.displayTitle,
      route.length - 1,
      route.map((movie) => movie.displayTitle).join(' → '),
    );
    if (text == null) return;
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// What the universe says once: a failed jump or constellation, and the
  /// explorer bichinhos just unlocked.
  void _announce(BuildContext context, MovieUniverseExploring state) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (state.failedTravel case final failed?) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.universeTravelError(failed.displayTitle) ?? ''),
        ),
      );
    }
    if (state.failedConstellation) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.universeConstellationError ?? '')),
      );
    }
    for (final slug in state.unlockedPets) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.universeUnlockedPet(petName(l10n, slug)) ?? ''),
          action: SnackBarAction(
            label: l10n?.universeSeePet ?? '',
            onPressed: () => context.router.root.push(const ShelterRoute()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<MovieUniverseCubit, MovieUniverseState>(
        bloc: _cubit,
        listenWhen: (_, state) =>
            state is MovieUniverseExploring &&
            (state.failedTravel != null ||
                state.failedConstellation ||
                state.unlockedPets.isNotEmpty),
        listener: (context, state) =>
            _announce(context, state as MovieUniverseExploring),
        child: MovieUniverseScreen(
          cubit: _cubit,
          onOpenMovie: (movie) => context.router.push(
            MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
          ),
          onAddToWatchlist: _addToWatchlist,
          onAddToShelves: _addToShelves,
          onShareRoute: _shareRoute,
        ),
      );
}
