import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/rating/rate_movie_cubit.dart';
import 'package:watch_logs_ui/rating/rate_movie_screen.dart';

/// Full-screen modal. Pops with true when the rating was saved or removed.
@RoutePage()
class RateMoviePage extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final MovieRating? current;
  final bool alreadyWatched;

  const RateMoviePage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.current,
    this.alreadyWatched = false,
  });

  @override
  State<RateMoviePage> createState() => _RateMoviePageState();
}

class _RateMoviePageState extends State<RateMoviePage> {
  late final RateMovieCubit _cubit = RateMovieCubit(
    movieId: widget.movieId,
    current: widget.current,
    alreadyWatched: widget.alreadyWatched,
    setMovieRating: GetIt.I<SetMovieRating>(),
    removeMovieRating: GetIt.I<RemoveMovieRating>(),
    getRecentEmotions: GetIt.I<GetRecentEmotions>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _finish(Future<bool> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context)?.ratingError ?? '';
    if (await action()) {
      if (mounted) context.router.maybePop(true);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) => RateMovieScreen(
    cubit: _cubit,
    movieTitle: widget.movieTitle,
    canRemove: widget.current != null,
    onSave: () => _finish(_cubit.save),
    onRemove: () => _finish(_cubit.remove),
  );
}
