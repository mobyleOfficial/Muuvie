import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/movie_panel/movie_watch_cubit.dart';
import 'package:watch_logs_ui/watch_logs_router.dart';

/// The user's state for a movie and the session actions, for the movie detail (F2.7).
class MovieWatchPanel extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final int? runtime;

  /// After a rating or a session is saved, so the rest of the detail can reload.
  final VoidCallback? onChanged;

  /// The other actions of the movie (shelves, CineClube...), next to the
  /// main button; null hides the button.
  final VoidCallback? onMore;

  const MovieWatchPanel({
    super.key,
    required this.movieId,
    required this.movieTitle,
    this.runtime,
    this.onChanged,
    this.onMore,
  });

  @override
  State<MovieWatchPanel> createState() => _MovieWatchPanelState();
}

class _MovieWatchPanelState extends State<MovieWatchPanel> {
  late final MovieWatchCubit _cubit = MovieWatchCubit(
    movieId: widget.movieId,
    getMovieWatchState: GetIt.I<GetMovieWatchState>(),
    logWatchSession: GetIt.I<LogWatchSession>(),
    startRewatch: GetIt.I<StartRewatch>(),
    setWatchingNow: GetIt.I<SetWatchingNow>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  int? get _runtime => (widget.runtime ?? 0) > 0 ? widget.runtime : null;

  /// Runs [action] once signed in, then shows [successMessage] or the generic error.
  Future<void> _act(
    Future<bool> Function() action, {
    String? successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (!await AuthGate.check(context)) return;
    if (_cubit.state is MovieWatchGuest) await _cubit.load();
    final ok = await action();
    final message = ok ? successMessage : l10n?.watchStateError;
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openLogSession() async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context)?.watchLogSaved ?? '';
    if (!await AuthGate.check(context) || !mounted) return;
    final log = await context.router.root.push<WatchLog>(
      LogSessionRoute(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        runtime: _runtime,
      ),
    );
    if (log != null) {
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      await _cubit.load();
      widget.onChanged?.call();
    }
  }

  Future<void> _openRating(MovieUserState userState) async {
    if (!await AuthGate.check(context) || !mounted) return;
    final changed = await context.router.root.push<bool>(
      RateMovieRoute(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        current: userState.rating,
        alreadyWatched: userState.isWatched,
      ),
    );
    if (changed == true) {
      await _cubit.load();
      widget.onChanged?.call();
    }
  }

  Future<void> _openHistory() async {
    await context.router.root.push(
      MovieHistoryRoute(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        runtime: _runtime,
      ),
    );
    await _cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MovieWatchCubit, MovieWatchState>(
      bloc: _cubit,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: MuuvieRadius.largeAll,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: switch (state) {
              MovieWatchLoading() => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              ),
              MovieWatchError() => Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n?.emptyStateRetry ?? ''),
                  onPressed: _cubit.load,
                ),
              ),
              // Every action asks to sign in first.
              MovieWatchGuest() => _PanelContent(
                userState: const MovieUserState(),
                isBusy: false,
                onLog: _openLogSession,
                onMarkWatched: () => _act(_cubit.markWatched),
                onRewatch: null,
                onRate: () => _openRating(const MovieUserState()),
                onToggleWatchingNow: () => _act(_cubit.toggleWatchingNow),
                onMore: widget.onMore,
              ),
              MovieWatchReady(:final userState, :final isBusy) => _PanelContent(
                userState: userState,
                isBusy: isBusy,
                runtime: _runtime,
                onLog: _openLogSession,
                onMarkWatched: () => _act(_cubit.markWatched),
                onRewatch: () => _act(
                  _cubit.startRewatch,
                  successMessage: l10n?.rewatchStarted,
                ),
                onRate: () => _openRating(userState),
                onToggleWatchingNow: () => _act(_cubit.toggleWatchingNow),
                onHistory: _openHistory,
                onMore: widget.onMore,
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// Status, the quick actions as icon tiles, the progress of the current
/// cycle and the main button.
class _PanelContent extends StatelessWidget {
  final MovieUserState userState;
  final bool isBusy;
  final int? runtime;
  final VoidCallback onLog;
  final VoidCallback onMarkWatched;
  final VoidCallback? onRewatch;
  final VoidCallback onRate;
  final VoidCallback onToggleWatchingNow;
  final VoidCallback? onHistory;
  final VoidCallback? onMore;

  const _PanelContent({
    required this.userState,
    required this.isBusy,
    this.runtime,
    required this.onLog,
    required this.onMarkWatched,
    required this.onRewatch,
    required this.onRate,
    required this.onToggleWatchingNow,
    this.onHistory,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final rating = userState.rating;
    final onRewatch = this.onRewatch;
    final onHistory = this.onHistory;
    final onMore = this.onMore;
    final (ratingBackground, ratingForeground) = rating == null
        ? (null, null)
        : MuuvieRatingBadge.colorsFor(rating.rating, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusHeader(userState: userState),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: !userState.isWatched
                  ? _ActionTile(
                      icon: Icons.check_circle_outline,
                      label: l10n?.systemShelfWatched ?? '',
                      onTap: isBusy ? null : onMarkWatched,
                    )
                  : userState.canRewatch && onRewatch != null
                  ? _ActionTile(
                      icon: Icons.replay,
                      label: l10n?.rewatchAction ?? '',
                      onTap: isBusy ? null : onRewatch,
                    )
                  : _ActionTile(
                      icon: Icons.check_circle,
                      label: l10n?.watchStatus(WatchStatus.watched) ?? '',
                      selected: true,
                    ),
            ),
            Expanded(
              child: _ActionTile(
                icon: rating == null
                    ? Icons.star_outline
                    : MuuvieRatingBadge.iconFor(rating.rating),
                label: rating == null
                    ? l10n?.ratingTitle ?? ''
                    : l10n?.rating(rating.rating) ?? '',
                hint: rating == null ? null : l10n?.ratingTitle,
                background: ratingBackground,
                foreground: ratingForeground,
                onTap: isBusy ? null : onRate,
              ),
            ),
            Expanded(
              child: _ActionTile(
                icon: userState.watchingNow
                    ? Icons.play_circle
                    : Icons.play_circle_outline,
                label: l10n?.watchingNowTitle ?? '',
                selected: userState.watchingNow,
                toggle: true,
                onTap: isBusy ? null : onToggleWatchingNow,
              ),
            ),
            if (onHistory != null)
              Expanded(
                child: _ActionTile(
                  icon: Icons.history,
                  label: l10n?.historyTitle ?? '',
                  onTap: onHistory,
                ),
              ),
          ],
        ),
        _ProgressBar(userState: userState, runtime: runtime),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: MuuvieRadius.mediumAll,
                  ),
                ),
                icon: const Icon(Icons.edit_calendar_outlined),
                label: Text(l10n?.watchLogAction ?? ''),
                onPressed: isBusy ? null : onLog,
              ),
            ),
            if (onMore != null) ...[
              const SizedBox(width: 8),
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: MuuvieRadius.mediumAll,
                  ),
                ),
                tooltip: l10n?.movieDetailActions ?? '',
                icon: const Icon(Icons.more_horiz),
                onPressed: onMore,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Quero ver, from the system shelves. Hidden when there is none.
class _StatusHeader extends StatelessWidget {
  final MovieUserState userState;

  const _StatusHeader({required this.userState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Já assisti already shows in the first tile.
    final status = userState.isWatched ? null : userState.status;
    if (status == null) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(Icons.bookmark, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 6),
            Text(
              l10n?.watchStatus(status) ?? '',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An icon in a circle over a short label; a disabled one keeps its look
/// when it only shows a state.
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  /// Read as a switch by the screen reader.
  final bool toggle;

  /// What a tap does when the label shows a state (e.g. the given rating).
  final String? hint;
  final Color? background;
  final Color? foreground;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
    this.toggle = false,
    this.hint,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final circle =
        background ??
        (selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest);
    final iconColor =
        foreground ??
        (selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface);

    return Semantics(
      button: onTap != null,
      toggled: toggle ? selected : null,
      selected: !toggle && selected ? true : null,
      hint: hint,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: MuuvieRadius.mediumAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: circle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: selected || background != null
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minutes bar of the current cycle while it is unfinished.
class _ProgressBar extends StatelessWidget {
  final MovieUserState userState;
  final int? runtime;

  const _ProgressBar({required this.userState, required this.runtime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = userState.progress;
    final percent = progress?.percent;
    if (progress == null || progress.completed || percent == null) {
      return const SizedBox.shrink();
    }
    final minutes = progress.minutes;
    final total = runtime;
    final label = minutes != null && total != null
        ? l10n?.movieProgressMinutes(minutes, total) ?? ''
        : l10n?.watchProgressPercent(percent) ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Semantics(
        label: label,
        child: ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: MuuvieRadius.pillAll,
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
