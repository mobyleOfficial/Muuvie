import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/maratona_detail_bloc.dart';
import 'package:maratonas_ui/detail/maratona_detail_state.dart';
import 'package:maratonas_ui/detail/movie_picker_sheet.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// One challenge (F7.5): the movies tied to it, and marking it with a movie
/// from the queue or from Já assisti while the maratona runs.
class ChallengeSheet extends StatelessWidget {
  final int challengeId;
  final ValueChanged<ChallengeLink> onOpenMovie;

  const ChallengeSheet({
    super.key,
    required this.challengeId,
    required this.onOpenMovie,
  });

  static Future<void> show(
    BuildContext context, {
    required MaratonaDetailCubit cubit,
    required int challengeId,
    required ValueChanged<ChallengeLink> onOpenMovie,
  }) => MuuvieBottomSheet.show<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: ChallengeSheet(challengeId: challengeId, onOpenMovie: onOpenMovie),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MaratonaDetailCubit, MaratonaDetailState>(
      builder: (context, state) {
        if (state is! MaratonaDetailSuccess) return const SizedBox.shrink();
        final maratona = state.maratona;
        final challenge = state.categories
            .expand((category) => category.challenges)
            .where((challenge) => challenge.id == challengeId)
            .firstOrNull;
        if (challenge == null) return const SizedBox.shrink();
        final running = maratona.status == MaratonaStatus.active;
        final canMark = maratona.joined && running;
        final color = maratonaColor(context, maratona.accentColor);

        return Material(
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.8,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        challenge.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: challenge.completed ? color : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            challenge.description,
                            style: textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      challenge.criteria != null
                          ? l10n?.maratonaChallengeAuto ?? ''
                          : l10n?.maratonaChallengeManual ?? '',
                      style: textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (challenge.links.isEmpty)
                    Text(
                      l10n?.maratonaLinksEmpty ?? '',
                      style: textTheme.bodyMedium,
                    ),
                  for (final link in challenge.links)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => onOpenMovie(link),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 36,
                          height: 54,
                          child: link.posterPath == null
                              ? const Icon(Icons.movie_outlined)
                              : CachedNetworkImage(
                                  imageUrl: TmdbImageUrl.buildPosterSmall(
                                    link.posterPath!,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      title: Text(link.title),
                      subtitle: link.source == ChallengeLinkSource.auto
                          ? Text(l10n?.maratonaLinkAuto ?? '')
                          : null,
                      trailing: canMark
                          ? IconButton(
                              tooltip: l10n?.maratonaUnlink,
                              icon: const Icon(Icons.close),
                              onPressed: () => _setLink(
                                context,
                                link.movieId,
                                linked: false,
                              ),
                            )
                          : null,
                    ),
                  const SizedBox(height: 12),
                  if (canMark)
                    FilledButton.icon(
                      onPressed: () => _pickMovie(context, maratona),
                      icon: const Icon(Icons.add),
                      label: Text(l10n?.maratonaLinkMovie ?? ''),
                    )
                  else
                    Text(
                      maratona.joined
                          ? l10n?.maratonaNotRunning ?? ''
                          : l10n?.maratonaJoinToMark ?? '',
                      style: textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickMovie(BuildContext context, Maratona maratona) async {
    final movieId = await MoviePickerSheet.show(
      context,
      queueShelfId: maratona.me?.queueShelfId,
    );
    if (movieId == null || !context.mounted) return;
    await _setLink(context, movieId, linked: true);
  }

  Future<void> _setLink(
    BuildContext context,
    int movieId, {
    required bool linked,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final error = await context.read<MaratonaDetailCubit>().setLink(
      challengeId,
      movieId,
      linked,
    );
    if (error == null) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          error == AppError.conflict
              ? l10n?.maratonaNotRunning ?? ''
              : l10n?.maratonaActionError ?? '',
        ),
      ),
    );
  }
}
