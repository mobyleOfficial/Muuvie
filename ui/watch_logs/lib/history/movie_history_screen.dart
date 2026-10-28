import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/history/movie_history_cubit.dart';
import 'package:watch_logs_ui/widgets/watch_log_tile.dart';

class MovieHistoryScreen extends StatelessWidget {
  final MovieHistoryCubit cubit;
  final String movieTitle;
  final int? runtime;
  final Future<void> Function(WatchLog log) onEdit;

  const MovieHistoryScreen({
    super.key,
    required this.cubit,
    required this.movieTitle,
    this.runtime,
    required this.onEdit,
  });

  Future<void> _confirmDelete(BuildContext context, WatchLog log) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.historyDeleteTitle ?? ''),
        content: Text(l10n?.historyDeleteMessage ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.cancel ?? ''),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n?.historyDelete ?? ''),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!await cubit.delete(log.id)) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n?.watchStateError ?? '')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.historyTitle ?? '')),
      body: BlocBuilder<MovieHistoryCubit, MovieHistoryState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          MovieHistoryLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          MovieHistoryError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          MovieHistorySuccess(:final logs) when logs.isEmpty =>
            MuuvieEmptyState(
              title: l10n?.historyEmpty ?? '',
              message: movieTitle,
            ),
          MovieHistorySuccess() => _HistoryList(
            state: state,
            cubit: cubit,
            movieTitle: movieTitle,
            runtime: runtime,
            onEdit: onEdit,
            onDelete: (log) => _confirmDelete(context, log),
          ),
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final MovieHistorySuccess state;
  final MovieHistoryCubit cubit;
  final String movieTitle;
  final int? runtime;
  final Future<void> Function(WatchLog log) onEdit;
  final Future<void> Function(WatchLog log) onDelete;

  const _HistoryList({
    required this.state,
    required this.cubit,
    required this.movieTitle,
    required this.runtime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final logs = state.logs;
    // Summary, then each log preceded by its cycle header when the cycle changes (F2.5).
    final items = <Widget>[
      _SummaryCard(summary: state.summary, movieTitle: movieTitle),
    ];
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      if (i == 0 || logs[i - 1].cycle != log.cycle) {
        items.add(_CycleHeader(cycle: log.cycle));
      }
      items.add(
        WatchLogTile(
          log: log,
          runtime: runtime,
          onEdit: log.self ? () => onEdit(log) : null,
          onDelete: log.self ? () => onDelete(log) : null,
        ),
      );
    }

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 300) cubit.loadMore();
        return false;
      },
      child: RefreshIndicator(
        onRefresh: cubit.load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            ...items,
            if (state.hasNext)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final WatchLogSummary summary;
  final String movieTitle;

  const _SummaryCard({required this.summary, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(movieTitle, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n?.historyMinutes(summary.totalMinutes) ?? ''),
            Text(l10n?.historySessions(summary.sessions) ?? ''),
            Text(l10n?.historyRewatches(summary.rewatches) ?? ''),
            if (summary.topEmotions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final emotion in summary.topEmotions)
                    Chip(
                      label: Text(l10n?.emotion(emotion) ?? emotion.wireValue),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CycleHeader extends StatelessWidget {
  final int cycle;

  const _CycleHeader({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = cycle <= 1
        ? l10n?.historyFirstWatch ?? ''
        : l10n?.historyRewatch(cycle - 1) ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
