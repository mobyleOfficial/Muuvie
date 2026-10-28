import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gamification_ui/gamification_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:social/feed/movie_activities_feed.dart';
import 'package:social_network/social_network.dart' show MovieActivityKind;

/// The movie detail's links to the modules that depend on movies_ui (F12).
class AppMovieDetailLinks implements MovieDetailLinks {
  const AppMovieDetailLinks();

  @override
  void openMaratona(BuildContext context, MovieEvent event) => context.router
      .push(MaratonaDetailRoute(slug: event.slug, title: event.title));

  @override
  void openCineClube(BuildContext context, MovieEvent event) => context.router
      .push(CineClubeDetailRoute(slug: event.slug, title: event.title));

  @override
  void createCineClube(BuildContext context, Movie movie) =>
      context.router.root.push(
        CineClubeEditorRoute(
          movie: CineClubeMovie(
            id: movie.id,
            title: movie.displayTitle,
            posterPath: movie.posterPath.isEmpty ? null : movie.posterPath,
            runtime: movie.info?.runtime,
          ),
        ),
      );

  @override
  void startWatchParty(BuildContext context, Movie movie) => context.router.root
      .push(WatchPartyRoute(movieId: movie.id, movieTitle: movie.displayTitle));

  @override
  Widget activities(
    int movieId, {
    ValueListenable<MovieActivityKind?>? kindRequests,
  }) => MovieActivitiesFeed(movieId: movieId, kindRequests: kindRequests);

  @override
  void openMovieShelves(BuildContext context, Movie movie) =>
      context.router.push(
        MovieShelvesRoute(movieId: movie.id, movieTitle: movie.displayTitle),
      );

  @override
  void openShelf(
    BuildContext context, {
    required int shelfId,
    required String shelfName,
    String? shelfColor,
  }) => context.router.push(
    ShelfDetailRoute(
      shelfId: shelfId,
      shelfName: shelfName,
      shelfColor: shelfColor,
    ),
  );
}
