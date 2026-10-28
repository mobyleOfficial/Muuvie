import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_job/import_job_cubit.dart';
import 'package:imports_ui/import_job/import_job_state.dart';

class ImportJobScreen extends StatelessWidget {
  final ImportJobCubit cubit;
  final VoidCallback onReviewUnmatched;
  final VoidCallback onImportAgain;

  const ImportJobScreen({
    super.key,
    required this.cubit,
    required this.onReviewUnmatched,
    required this.onImportAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MuuvieModalScreen(
      title: l10n?.importTitle ?? '',
      body: BlocConsumer<ImportJobCubit, ImportJobState>(
        bloc: cubit,
        listenWhen: (_, state) =>
            state is ImportJobSuccess && state.actionFailed,
        listener: (context, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n?.importActionError ?? ''))),
        builder: (context, state) => switch (state) {
          ImportJobLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ImportJobError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ImportJobSuccess(:final job) => switch (job.status) {
            ImportStatus.pending || ImportStatus.reading => _Waiting(
              title: l10n?.importReadingTitle ?? '',
              message: l10n?.importReadingMessage ?? '',
            ),
            ImportStatus.preview => _Preview(state: state, cubit: cubit),
            ImportStatus.importing => _Waiting(
              title: l10n?.importImportingTitle ?? '',
              message: l10n?.importImportingMessage ?? '',
              progress: job.progress,
              progressLabel: job.total > 0
                  ? l10n?.importImportingProgress(job.processed, job.total)
                  : null,
            ),
            ImportStatus.done => _Report(
              job: job,
              onReviewUnmatched: onReviewUnmatched,
              onImportAgain: onImportAgain,
            ),
            ImportStatus.failed => MuuvieEmptyState(
              title: l10n?.importFailedTitle ?? '',
              message: job.error ?? '',
              action: onImportAgain,
              actionLabel: l10n?.importAgain ?? '',
            ),
            ImportStatus.cancelled => MuuvieEmptyState(
              title: l10n?.importCancelledTitle ?? '',
              message: l10n?.importCancelledMessage ?? '',
              action: onImportAgain,
              actionLabel: l10n?.importAgain ?? '',
            ),
          },
        },
      ),
    );
  }
}

/// Reading or writing: the user may leave, the job goes on on the server.
class _Waiting extends StatelessWidget {
  final String title;
  final String message;
  final double? progress;
  final String? progressLabel;

  const _Waiting({
    required this.title,
    required this.message,
    this.progress,
    this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Semantics(
            label: progressLabel ?? title,
            child: LinearProgressIndicator(value: progress),
          ),
          if (progressLabel != null) ...[
            const SizedBox(height: 8),
            Text(progressLabel!, style: textTheme.labelMedium),
          ],
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// F3.5: what will be written, the lists to bring and their visibility.
class _Preview extends StatelessWidget {
  final ImportJobSuccess state;
  final ImportJobCubit cubit;

  const _Preview({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final preview = state.job.preview;
    if (preview == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n?.importPreviewTitle ?? '', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _CountRow(
          icon: Icons.check_circle_outline,
          text: l10n?.importPreviewWatched(preview.watched) ?? '',
        ),
        _CountRow(
          icon: Icons.bookmark_border,
          text: l10n?.importPreviewWatchlist(preview.watchlist) ?? '',
        ),
        if (preview.favorites > 0)
          _CountRow(
            icon: Icons.favorite_border,
            text: l10n?.importPreviewFavorites(preview.favorites) ?? '',
          ),
        if (preview.logs > 0)
          _CountRow(
            icon: Icons.event_outlined,
            text: l10n?.importPreviewLogs(preview.logs) ?? '',
          ),
        const SizedBox(height: 24),
        Text(
          l10n?.importPreviewLists ?? '',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (preview.lists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n?.importPreviewNoLists ?? '',
              style: textTheme.bodyMedium,
            ),
          ),
        for (final list in preview.lists)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: state.selectedLists.contains(list.externalId),
            onChanged: state.submitting
                ? null
                : (_) => cubit.toggleList(list.externalId),
            title: Text(list.title),
            subtitle: Text(l10n?.locadoraMoviesCount(list.movieCount) ?? ''),
          ),
        const SizedBox(height: 24),
        Text(
          l10n?.importPreviewVisibility ?? '',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        MuuvieVisibilitySelector(
          value: state.visibility,
          onChanged: cubit.setVisibility,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: MuuvieButton(
            onPressed: state.submitting ? null : cubit.confirm,
            child: Text(l10n?.importConfirm ?? ''),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: MuuvieTextButton(
            onPressed: state.submitting ? null : cubit.cancel,
            child: Text(l10n?.importCancel ?? ''),
          ),
        ),
      ],
    );
  }
}

/// F3.6: counts, the confirmation queue and importing again.
class _Report extends StatelessWidget {
  final ImportJob job;
  final VoidCallback onReviewUnmatched;
  final VoidCallback onImportAgain;

  const _Report({
    required this.job,
    required this.onReviewUnmatched,
    required this.onImportAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final counts = job.counts ?? const ImportCounts();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n?.importDoneTitle ?? '', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _CountRow(
          icon: Icons.check_circle_outline,
          text: l10n?.importPreviewWatched(counts.watched) ?? '',
        ),
        _CountRow(
          icon: Icons.bookmark_border,
          text: l10n?.importPreviewWatchlist(counts.watchlist) ?? '',
        ),
        if (counts.favorites > 0)
          _CountRow(
            icon: Icons.favorite_border,
            text: l10n?.importPreviewFavorites(counts.favorites) ?? '',
          ),
        if (counts.logs > 0)
          _CountRow(
            icon: Icons.event_outlined,
            text: l10n?.importPreviewLogs(counts.logs) ?? '',
          ),
        if (counts.lists > 0)
          _CountRow(
            icon: Icons.shelves,
            text: l10n?.importDoneShelves(counts.lists) ?? '',
          ),
        if (counts.keptFromMuuvie > 0)
          _CountRow(
            icon: Icons.lock_outline,
            text: l10n?.importDoneKept(counts.keptFromMuuvie) ?? '',
          ),
        const SizedBox(height: 32),
        if (counts.unmatched > 0) ...[
          SizedBox(
            width: double.infinity,
            child: MuuvieButton(
              onPressed: onReviewUnmatched,
              child: Text(l10n?.importReviewUnmatched(counts.unmatched) ?? ''),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: MuuvieTextButton(
            onPressed: onImportAgain,
            child: Text(l10n?.importAgain ?? ''),
          ),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CountRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}
