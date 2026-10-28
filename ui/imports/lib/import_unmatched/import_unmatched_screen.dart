import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_cubit.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_state.dart';

class ImportUnmatchedScreen extends StatelessWidget {
  final ImportUnmatchedCubit cubit;

  const ImportUnmatchedScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MuuvieModalScreen(
      title: l10n?.importUnmatchedTitle ?? '',
      leading: const BackButton(),
      body: BlocConsumer<ImportUnmatchedCubit, ImportUnmatchedState>(
        bloc: cubit,
        listenWhen: (_, state) =>
            state is ImportUnmatchedSuccess && state.actionFailed,
        listener: (context, _) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n?.importActionError ?? ''))),
        builder: (context, state) => switch (state) {
          ImportUnmatchedLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ImportUnmatchedError(:final message) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ImportUnmatchedSuccess(:final items) when items.isEmpty =>
            MuuvieEmptyState(
              illustration: MuuvieIllustration.search,
              title: l10n?.importUnmatchedEmpty ?? '',
              message: '',
            ),
          ImportUnmatchedSuccess() =>
            NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 300) cubit.loadMore();
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(
                    l10n?.importUnmatchedHint ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  for (final item in state.items)
                    _UnmatchedCard(
                      item: item,
                      busy: state.resolving.contains(item.id),
                      onPick: (candidate) => cubit.resolve(item, candidate),
                      onSkip: () => cubit.resolve(item, null),
                    ),
                  if (state.hasNext)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
        },
      ),
    );
  }
}

class _UnmatchedCard extends StatelessWidget {
  final UnmatchedItem item;
  final bool busy;
  final ValueChanged<MovieCandidate> onPick;
  final VoidCallback onSkip;

  const _UnmatchedCard({
    required this.item,
    required this.busy,
    required this.onPick,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final pending = item.resolution == UnmatchedResolution.pending;
    final year = item.year;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    year == null ? item.title : '${item.title} ($year)',
                    style: textTheme.titleMedium,
                  ),
                ),
                if (!pending)
                  Text(
                    item.resolution == UnmatchedResolution.matched
                        ? l10n?.importUnmatchedMatched ?? ''
                        : l10n?.importUnmatchedSkipped ?? '',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            if (pending) ...[
              const SizedBox(height: 12),
              if (item.candidates.isEmpty)
                Text(
                  l10n?.importUnmatchedNoCandidates ?? '',
                  style: textTheme.bodySmall,
                )
              else
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: item.candidates.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _CandidateTile(
                      candidate: item.candidates[index],
                      onTap: busy ? null : () => onPick(item.candidates[index]),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: MuuvieTextButton(
                  onPressed: busy ? null : onSkip,
                  child: Text(l10n?.importUnmatchedSkip ?? ''),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final MovieCandidate candidate;
  final VoidCallback? onTap;

  const _CandidateTile({required this.candidate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final posterPath = candidate.posterPath;
    final year = candidate.year;
    final label = year == null ? candidate.title : '${candidate.title} ($year)';

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: MuuvieRadius.smallAll,
        child: SizedBox(
          width: 92,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: MuuvieRadius.smallAll,
                child: SizedBox(
                  width: 92,
                  height: 138,
                  child: posterPath == null
                      ? ColoredBox(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.movie_outlined),
                        )
                      : CachedNetworkImage(
                          imageUrl: TmdbImageUrl.buildPosterSmall(posterPath),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
