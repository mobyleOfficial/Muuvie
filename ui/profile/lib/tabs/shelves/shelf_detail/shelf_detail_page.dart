import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:movies/movies.dart' show GetGenres, Movie;
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:shelves/shelves.dart';
import 'package:watch_logs/watch_logs.dart' show WatchLog;
import 'package:watch_logs_ui/watch_logs_router.dart';

import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_screen.dart';
import 'package:profile_ui/tabs/shelves/shelf_picker_bottom_sheet.dart';

@RoutePage()
class ShelfDetailPage extends StatefulWidget {
  final int shelfId;
  final String shelfName;
  final String? shelfColor;

  const ShelfDetailPage({
    super.key,
    required this.shelfId,
    required this.shelfName,
    this.shelfColor,
  });

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  late final ShelfDetailCubit _cubit = ShelfDetailCubit(
    shelfId: widget.shelfId,
    getShelf: GetIt.I<GetShelf>(),
    getShelfMovies: GetIt.I<GetShelfMovies>(),
    sortShelf: GetIt.I<SortShelf>(),
    reorderShelfMovies: GetIt.I<ReorderShelfMovies>(),
    removeMovieFromShelf: GetIt.I<RemoveMovieFromShelf>(),
    transferShelfMovies: GetIt.I<TransferShelfMovies>(),
    addMoviesToShelf: GetIt.I<AddMoviesToShelf>(),
    setShelfSaved: GetIt.I<SetShelfSaved>(),
  );

  late final Future<Result<List<GenreOption>>> _genres = GetIt.I<GetGenres>()()
      .then(
        (result) => switch (result) {
          Success(:final data) => Success(
            data.map((g) => GenreOption(g.id, g.name)).toList(),
          ),
          Failure(:final error) => Failure(error),
        },
      );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShelfDetailScreen(
    cubit: _cubit,
    genres: _genres,
    onMovieTap: (movie) => context.router.push(
      MovieDetailRoute(movieId: movie.movieId, movieTitle: movie.title),
    ),
    onAddMovies: () async {
      final selected = await context.router.root.push<List<Movie>>(
        const AddMoviesToShelfRoute(),
      );
      if (selected == null || selected.isEmpty) return false;
      return _cubit.addMovies(selected.map((movie) => movie.id).toList());
    },
    onLogSession: (movie) async {
      final messenger = ScaffoldMessenger.of(context);
      final saved = AppLocalizations.of(context)?.watchLogSaved ?? '';
      final log = await context.router.root.push<WatchLog>(
        LogSessionRoute(
          movieId: movie.movieId,
          movieTitle: movie.title,
          runtime: movie.runtime,
        ),
      );
      if (log == null) return;
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      await _cubit.load();
    },
    onImport: () => context.router.root.push(const ImportStartRoute()),
    onOpenOwner: (shelf) => context.router.push(
      PublicProfileRoute(userId: shelf.ownerId, displayName: shelf.ownerName),
    ),
    onPickTargetShelf: () => ShelfPickerBottomSheet.show(
      context,
      loadShelves: () =>
          GetIt.I<GetUserShelves>()(const GetUserShelvesParams()),
      excludedShelfId: widget.shelfId,
    ),
  );
}
