import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';

import 'package:profile_ui/tabs/lists/create_list/create_list_bloc.dart';
import 'package:profile_ui/tabs/lists/create_list/create_list_screen.dart';

@RoutePage()
class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  late final CreateListCubit _cubit = CreateListCubit(
    GetIt.I<CreateMovieList>(),
    GetIt.I<SearchMovies>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CreateListScreen(
        cubit: _cubit,
        searchMovies: GetIt.I<SearchMovies>(),
      );
}
