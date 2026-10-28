import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';

import 'package:search/most_popular/most_popular_bloc.dart';
import 'package:search/most_popular/most_popular_screen.dart';

@RoutePage()
class MostPopularPage extends StatefulWidget {
  const MostPopularPage({super.key});

  @override
  State<MostPopularPage> createState() => _MostPopularPageState();
}

class _MostPopularPageState extends State<MostPopularPage> {
  late final MostPopularCubit _cubit = MostPopularCubit(
    GetIt.I<DiscoverMovies>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MostPopularScreen(
    cubit: _cubit,
    onMovieTap: (movieId, movieTitle) => context.router.push(
      MovieDetailRoute(movieId: movieId, movieTitle: movieTitle),
    ),
  );
}
