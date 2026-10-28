import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart' show Movie;
import 'package:profile_ui/profile_router.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/tabs/shelves/shelves_bloc.dart';
import 'package:profile_ui/tabs/shelves/shelves_screen.dart';

/// The Estantes tab of a profile. Editable only on my own profile.
class ShelvesPage extends StatefulWidget {
  /// The owner, or `me` for the current user.
  final String userId;

  const ShelvesPage({super.key, this.userId = 'me'});

  @override
  State<ShelvesPage> createState() => _ShelvesPageState();
}

class _ShelvesPageState extends State<ShelvesPage> {
  late final ShelvesCubit _cubit = ShelvesCubit(
    userId: widget.userId,
    getUserShelves: GetIt.I<GetUserShelves>(),
    saveShelf: GetIt.I<SaveShelf>(),
    deleteShelf: GetIt.I<DeleteShelf>(),
    reorderShelves: GetIt.I<ReorderShelves>(),
    addMoviesToShelf: GetIt.I<AddMoviesToShelf>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShelvesScreen(
    cubit: _cubit,
    readOnly: widget.userId != 'me',
    onOpenSaved: widget.userId == 'me'
        ? () => context.router.push(const SavedShelvesRoute())
        : null,
    onOpenShelf: (shelf) async {
      await context.router.push(
        ShelfDetailRoute(
          shelfId: shelf.id,
          shelfName: shelf.name,
          shelfColor: shelf.color,
        ),
      );
      // Counters and posters may have changed inside the shelf.
      _cubit.load();
    },
    onAddMovies: (shelf) async {
      final selected = await context.router.root.push<List<Movie>>(
        const AddMoviesToShelfRoute(),
      );
      if (selected == null || selected.isEmpty) return;
      await _cubit.addMovies(shelf, selected.map((movie) => movie.id).toList());
    },
  );
}
