import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:social_network/social_network.dart' show MovieActivityKind;

/// What the movie detail opens in modules that depend on movies_ui
/// (maratonas, CineClubes, the watch party and the Atts cards). The app
/// implements it and registers it in GetIt, so movies_ui does not depend on
/// them (F12).
abstract interface class MovieDetailLinks {
  /// The current one when the app registered it; null in isolated tests,
  /// where the detail shows only what lives in movies_ui.
  static MovieDetailLinks? get current =>
      GetIt.I.isRegistered<MovieDetailLinks>()
      ? GetIt.I<MovieDetailLinks>()
      : null;

  void openMaratona(BuildContext context, MovieEvent event);

  void openCineClube(BuildContext context, MovieEvent event);

  /// The CineClube editor with [movie] as the first session.
  void createCineClube(BuildContext context, Movie movie);

  void startWatchParty(BuildContext context, Movie movie);

  /// The Comunidade tab: everything people did with the movie (B13.3). Each
  /// new value of [kindRequests] selects that filter.
  Widget activities(
    int movieId, {
    ValueListenable<MovieActivityKind?>? kindRequests,
  });

  /// "Estantes com este filme": public custom shelves holding it (B13.2).
  void openMovieShelves(BuildContext context, Movie movie);

  /// One of those shelves (B13.5).
  void openShelf(
    BuildContext context, {
    required int shelfId,
    required String shelfName,
    String? shelfColor,
  });
}
