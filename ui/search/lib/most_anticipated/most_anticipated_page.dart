import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

import 'package:search/most_anticipated/most_anticipated_bloc.dart';
import 'package:search/most_anticipated/most_anticipated_screen.dart';

@RoutePage()
class MostAnticipatedPage extends StatefulWidget {
  const MostAnticipatedPage({super.key});

  @override
  State<MostAnticipatedPage> createState() => _MostAnticipatedPageState();
}

class _MostAnticipatedPageState extends State<MostAnticipatedPage> {
  late final MostAnticipatedCubit _cubit = MostAnticipatedCubit(
    GetIt.I<DiscoverMovies>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MostAnticipatedScreen(
    cubit: _cubit,
    onMovieTap: (movieId, movieTitle) => context.router.push(
      MovieDetailRoute(movieId: movieId, movieTitle: movieTitle),
    ),
  );
}
