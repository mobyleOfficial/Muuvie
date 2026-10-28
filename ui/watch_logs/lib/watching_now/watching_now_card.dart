import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/watch_logs_router.dart';

/// "Assistindo agora" with the minutes bar, for the profile header (F2.6).
/// Renders nothing when the user is not watching anything.
class WatchingNowCard extends StatefulWidget {
  /// `me` for the current user.
  final String userId;

  /// Opens the movie detail.
  final void Function(WatchingNow movie)? onOpenMovie;

  const WatchingNowCard({super.key, required this.userId, this.onOpenMovie});

  @override
  State<WatchingNowCard> createState() => _WatchingNowCardState();
}

class _WatchingNowCardState extends State<WatchingNowCard> {
  final GetWatchingNow _getWatchingNow = GetIt.I<GetWatchingNow>();
  WatchingNow? _movie;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _getWatchingNow(widget.userId);
    if (!mounted) return;
    if (result case Success(:final data)) setState(() => _movie = data);
  }

  Future<void> _logSession(WatchingNow movie) async {
    final log = await context.router.root.push<WatchLog>(
      LogSessionRoute(
        movieId: movie.movieId,
        movieTitle: movie.title,
        runtime: movie.runtime,
      ),
    );
    if (log != null) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movie;
    if (movie == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final progress = movie.progress;
    final percent = progress?.percent;
    final runtime = movie.runtime;
    // Without a runtime the bar is drawn from the percent.
    final minutes =
        progress?.minutes ??
        (runtime != null && percent != null ? runtime * percent ~/ 100 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: MuuvieMovieProgressCard(
              title: movie.title,
              subtitle: l10n?.watchingNowTitle,
              posterPath: movie.posterPath,
              minutesWatched: minutes,
              runtimeMinutes: runtime,
              completed: progress?.completed ?? false,
              onTap: widget.onOpenMovie == null
                  ? null
                  : () => widget.onOpenMovie!(movie),
            ),
          ),
          if (widget.userId == 'me')
            IconButton(
              tooltip: l10n?.watchLogAction ?? '',
              icon: const Icon(Icons.edit_calendar_outlined),
              onPressed: () => _logSession(movie),
            ),
        ],
      ),
    );
  }
}
