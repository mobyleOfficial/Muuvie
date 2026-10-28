import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';

import 'package:profile_ui/tabs/lists/create_list/add_movies_screen.dart';

@RoutePage()
class AddMoviesToShelfPage extends StatelessWidget {
  const AddMoviesToShelfPage({super.key});

  @override
  Widget build(BuildContext context) => AddMoviesScreen(
    searchMovies: GetIt.I<SearchMovies>(),
    alreadySelected: const [],
  );
}
