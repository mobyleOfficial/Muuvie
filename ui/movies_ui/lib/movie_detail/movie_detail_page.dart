import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_screen.dart';
import 'package:common/common.dart';
import 'package:shelves_ui/shelves_router.dart';

@RoutePage()
class MovieDetailPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieDetailPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieDetailCubit _cubit = MovieDetailCubit(
    GetIt.I<GetMovieDetail>(),
    widget.movieId,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieDetailScreen(
    cubit: _cubit,
    onAddToShelves: (movieId, movieTitle) async {
      final messenger = ScaffoldMessenger.of(context);
      final l10n = AppLocalizations.of(context);
      final count = await context.router.root.push<int>(
        AddToShelvesRoute(movieId: movieId, movieTitle: movieTitle),
      );
      if (count != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n?.addToShelvesSaved(count) ?? '')),
        );
      }
    },
  );
}
