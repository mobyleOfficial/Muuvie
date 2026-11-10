import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_start/import_start_cubit.dart';
import 'package:imports_ui/import_start/import_start_state.dart';
import 'package:imports_ui/widgets/import_status_label.dart';

class ImportStartScreen extends StatelessWidget {
  final ImportStartCubit cubit;
  final VoidCallback onStartFilmow;
  final ValueChanged<ImportSource> onStartFromFile;
  final ValueChanged<ImportJob> onOpenJob;

  const ImportStartScreen({
    super.key,
    required this.cubit,
    required this.onStartFilmow,
    required this.onStartFromFile,
    required this.onOpenJob,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MuuvieModalScreen(
      title: l10n?.importTitle ?? '',
      body: BlocBuilder<ImportStartCubit, ImportStartState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          ImportStartLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ImportStartError(:final message) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ImportStartSuccess() => _StartContent(
            state: state,
            onStartFilmow: onStartFilmow,
            onStartFromFile: onStartFromFile,
            onOpenJob: onOpenJob,
          ),
        },
      ),
    );
  }
}

class _StartContent extends StatelessWidget {
  final ImportStartSuccess state;
  final VoidCallback onStartFilmow;
  final ValueChanged<ImportSource> onStartFromFile;
  final ValueChanged<ImportJob> onOpenJob;

  const _StartContent({
    required this.state,
    required this.onStartFilmow,
    required this.onStartFromFile,
    required this.onOpenJob,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final active = state.activeJob;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(
          l10n?.importIntro ?? '',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 24),
        if (state.uploadProgress case final progress?) ...[
          Text(l10n?.importUploading ?? '', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            semanticsLabel: l10n?.importUploading,
            semanticsValue: '${(progress * 100).round()}%',
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: MuuvieButton(
            // A running import is resumed, never started twice (409 on the server).
            onPressed: state.starting
                ? null
                : active != null
                ? () => onOpenJob(active)
                : onStartFilmow,
            child: state.starting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    active != null
                        ? l10n?.importStatusLabel(active.status.wireValue) ?? ''
                        : l10n?.importStartFilmow ?? '',
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // The server allows one active import per source and answers 409 for a
        // second one, which the page reports.
        for (final source in ImportSource.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.starting
                    ? null
                    : () => onStartFromFile(source),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.upload_file),
                label: Text(switch (source) {
                  ImportSource.filmow => l10n?.importStartFilmowFile ?? '',
                  ImportSource.letterboxd =>
                    l10n?.importStartLetterboxdFile ?? '',
                }),
              ),
            ),
          ),
        if (state.history.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            l10n?.importHistoryTitle ?? '',
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final job in state.history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text('${job.source.displayName} · ${job.inputRef}'),
              subtitle: Text(
                MaterialLocalizations.of(
                  context,
                ).formatMediumDate(job.createdAt.toLocal()),
              ),
              trailing: ImportStatusLabel(status: job.status),
              onTap: () => onOpenJob(job),
            ),
        ],
      ],
    );
  }
}
