import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/about_tab.dart';
import 'package:maratonas_ui/detail/challenges_tab.dart';
import 'package:maratonas_ui/detail/discovery_tab.dart';
import 'package:maratonas_ui/detail/maratona_detail_bloc.dart';
import 'package:maratonas_ui/detail/maratona_detail_state.dart';
import 'package:maratonas_ui/detail/queue_tab.dart';
import 'package:maratonas_ui/detail/ranking_tab.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';
import 'package:shelves/shelves.dart';

/// The maratona detail (F7.3): header with the user's progress and the join
/// button, then Sobre · Desafios · Minha Fila · Descoberta · Ranking.
class MaratonaDetailScreen extends StatelessWidget {
  final MaratonaDetailCubit cubit;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final ValueChanged<MaratonaUser> onOpenUser;
  final void Function(int movieId, String title) onOpenMovie;
  final ValueChanged<Maratona> onOpenQueue;
  final ValueChanged<MaratonaChallenge> onOpenChallenge;
  final ValueChanged<String> onOpenLink;

  const MaratonaDetailScreen({
    super.key,
    required this.cubit,
    required this.onJoin,
    required this.onLeave,
    required this.onEdit,
    required this.onCancel,
    required this.onOpenUser,
    required this.onOpenMovie,
    required this.onOpenQueue,
    required this.onOpenChallenge,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<MaratonaDetailCubit, MaratonaDetailState>(
        builder: (context, state) => switch (state) {
          MaratonaDetailLoading() => const Center(
            child: MuuvieActivityIndicator(),
          ),
          MaratonaDetailError() => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          final MaratonaDetailSuccess success => DefaultTabController(
            length: 5,
            child: Column(
              children: [
                _Header(
                  state: success,
                  onJoin: onJoin,
                  onLeave: onLeave,
                  onEdit: onEdit,
                  onCancel: onCancel,
                ),
                MuuvieTabBar(
                  isScrollable: true,
                  tabs: [
                    l10n?.maratonaTabAbout ?? '',
                    l10n?.maratonaTabChallenges ?? '',
                    l10n?.maratonaTabQueue ?? '',
                    l10n?.maratonaTabDiscovery ?? '',
                    l10n?.maratonaTabRanking ?? '',
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MuuvieKeepAliveTab(
                        child: MaratonaAboutTab(
                          maratona: success.maratona,
                          onOpenUser: onOpenUser,
                          onOpenSocialLink: success.maratona.socialLink == null
                              ? null
                              : () => onOpenLink(success.maratona.socialLink!),
                        ),
                      ),
                      MaratonaChallengesTab(
                        maratona: success.maratona,
                        categories: success.categories,
                        onOpenChallenge: onOpenChallenge,
                      ),
                      MuuvieKeepAliveTab(
                        child: MaratonaQueueTab(
                          maratona: success.maratona,
                          onOpenMovie: (ShelfMovie movie) =>
                              onOpenMovie(movie.movieId, movie.title),
                          onOpenShelf: () => onOpenQueue(success.maratona),
                        ),
                      ),
                      MuuvieKeepAliveTab(
                        child: MaratonaDiscoveryTab(
                          maratona: success.maratona,
                          categories: success.categories,
                          onOpenMovie: (movie) =>
                              onOpenMovie(movie.id, movie.title),
                        ),
                      ),
                      MuuvieKeepAliveTab(
                        child: MaratonaRankingTab(
                          maratona: success.maratona,
                          onOpenUser: onOpenUser,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MaratonaDetailSuccess state;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _Header({
    required this.state,
    required this.onJoin,
    required this.onLeave,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final maratona = state.maratona;
    final me = maratona.me;
    final level = maratona.level(me?.levelId);
    final goal = level?.minChallenges ?? maratona.totalChallenges;
    final done = state.completed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaratonaLogo(
                title: maratona.title,
                logoUrl: maratona.logoUrl,
                accentColor: maratona.accentColor,
                size: 64,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        maratona.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      maratonaPeriod(l10n, maratona.startsOn, maratona.endsOn),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        MaratonaBadge(
                          label: maratona.status.label(l10n),
                          highlighted: maratona.status == MaratonaStatus.active,
                        ),
                        MaratonaBadge(
                          label:
                              l10n?.maratonaParticipants(
                                maratona.totalParticipants,
                              ) ??
                              '',
                          icon: Icons.people_outline,
                        ),
                        if (maratona.trusted)
                          MaratonaBadge(
                            label: l10n?.maratonaFilterCurated ?? '',
                            icon: Icons.verified_outlined,
                          ),
                        if (maratona.hasPassword)
                          MaratonaBadge(
                            label: l10n?.maratonaLocked ?? '',
                            icon: Icons.lock_outline,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (maratona.canEdit && maratona.status.open)
                PopupMenuButton<VoidCallback>(
                  tooltip: l10n?.activityMoreOptions,
                  onSelected: (action) => action(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: onEdit,
                      child: Text(l10n?.maratonaEdit ?? ''),
                    ),
                    PopupMenuItem(
                      value: onCancel,
                      child: Text(l10n?.maratonaCancel ?? ''),
                    ),
                  ],
                ),
            ],
          ),
          if (me != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: goal == 0 ? 0 : (done / goal).clamp(0, 1),
                    color: maratonaColor(context, maratona.accentColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    // The value stays the default percentage: the text next
                    // to the bar says it in words.
                    semanticsLabel: level?.name,
                  ),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: Text(
                    l10n?.maratonaMyProgress(done, goal) ?? '',
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
            ),
            if (level != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${l10n?.maratonaJoinLevel ?? ''}: ${level.name}',
                  style: textTheme.bodySmall,
                ),
              ),
          ],
          if (maratona.status.open) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: me == null
                  ? FilledButton.icon(
                      onPressed: state.busy ? null : onJoin,
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(l10n?.maratonaJoin ?? ''),
                    )
                  : OutlinedButton(
                      onPressed: state.busy ? null : onLeave,
                      child: Text(l10n?.maratonaLeave ?? ''),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
