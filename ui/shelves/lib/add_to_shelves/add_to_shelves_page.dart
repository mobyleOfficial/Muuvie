import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shelves/shelves.dart';

import 'package:shelves_ui/add_to_shelves/add_to_shelves_bloc.dart';
import 'package:shelves_ui/add_to_shelves/add_to_shelves_screen.dart';

/// Full-screen modal. Pops with how many shelves received the movie, or null.
@RoutePage()
class AddToShelvesPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const AddToShelvesPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<AddToShelvesPage> createState() => _AddToShelvesPageState();
}

class _AddToShelvesPageState extends State<AddToShelvesPage> {
  late final AddToShelvesCubit _cubit = AddToShelvesCubit(
    movieId: widget.movieId,
    getUserShelves: GetIt.I<GetUserShelves>(),
    getMovieShelves: GetIt.I<GetMovieShelves>(),
    addMovieToShelves: GetIt.I<AddMovieToShelves>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AddToShelvesScreen(
    cubit: _cubit,
    movieTitle: widget.movieTitle,
    onSave: () async {
      final count = await _cubit.save();
      if (count != null && context.mounted) context.router.maybePop(count);
      return count != null;
    },
  );
}
