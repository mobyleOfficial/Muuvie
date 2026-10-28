import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/log_session/log_session_cubit.dart';
import 'package:watch_logs_ui/log_session/log_session_screen.dart';

/// Full-screen modal. Pops with the saved [WatchLog], or null.
///
/// The movie is [movieId] (database id) or, for movies seen only on TMDB,
/// [tmdbId]. Pass [existing] to edit a session.
@RoutePage()
class LogSessionPage extends StatefulWidget {
  final int? movieId;
  final int? tmdbId;
  final String movieTitle;
  final int? runtime;
  final WatchLog? existing;

  const LogSessionPage({
    super.key,
    this.movieId,
    this.tmdbId,
    required this.movieTitle,
    this.runtime,
    this.existing,
  });

  @override
  State<LogSessionPage> createState() => _LogSessionPageState();
}

class _LogSessionPageState extends State<LogSessionPage> {
  late final LogSessionCubit _cubit = LogSessionCubit(
    movieId: widget.movieId,
    tmdbId: widget.tmdbId,
    movieTitle: widget.movieTitle,
    runtime: widget.runtime,
    existing: widget.existing,
    logWatchSession: GetIt.I<LogWatchSession>(),
    updateWatchLog: GetIt.I<UpdateWatchLog>(),
    getRecentEmotions: GetIt.I<GetRecentEmotions>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LogSessionScreen(
    cubit: _cubit,
    movieTitle: widget.movieTitle,
    isEditing: widget.existing != null,
    onSave: () async {
      final log = await _cubit.save();
      if (log != null && context.mounted) context.router.maybePop(log);
      return log != null;
    },
  );
}
