import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/history/movie_history_cubit.dart';
import 'package:watch_logs_ui/history/movie_history_screen.dart';
import 'package:watch_logs_ui/watch_logs_router.dart';

@RoutePage()
class MovieHistoryPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final int? runtime;

  /// Null for the current user.
  final String? userId;

  const MovieHistoryPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.runtime,
    this.userId,
  });

  @override
  State<MovieHistoryPage> createState() => _MovieHistoryPageState();
}

class _MovieHistoryPageState extends State<MovieHistoryPage> {
  late final MovieHistoryCubit _cubit = MovieHistoryCubit(
    movieId: widget.movieId,
    userId: widget.userId,
    getMovieLogs: GetIt.I<GetMovieLogs>(),
    deleteWatchLog: GetIt.I<DeleteWatchLog>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MovieHistoryScreen(
    cubit: _cubit,
    movieTitle: widget.movieTitle,
    runtime: widget.runtime,
    onEdit: (log) async {
      final updated = await context.router.root.push<WatchLog>(
        LogSessionRoute(
          movieId: widget.movieId,
          movieTitle: widget.movieTitle,
          runtime: widget.runtime,
          existing: log,
        ),
      );
      if (updated != null) await _cubit.load();
    },
  );
}
