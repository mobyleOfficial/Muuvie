import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/detail/about_tab.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_bloc.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_state.dart';
import 'package:cineclubes_ui/detail/participants_tab.dart';
import 'package:cineclubes_ui/detail/progress_tab.dart';
import 'package:cineclubes_ui/widgets/cineclube_labels.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas_ui/widgets/maratona_labels.dart';

/// The CineClube detail (F8.3): header with the user's progress and the join
/// button, the sessions of a cycle, then Sobre · Progresso · Participantes.
class CineClubeDetailScreen extends StatelessWidget {
  final CineClubeDetailCubit cubit;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final ValueChanged<CineClubeUser> onOpenUser;
  final ValueChanged<CineClubeMovie> onOpenMovie;
  final ValueChanged<String> onOpenLink;

  const CineClubeDetailScreen({
    super.key,
    required this.cubit,
    required this.onJoin,
    required this.onLeave,
    required this.onEdit,
    required this.onCancel,
    required this.onOpenUser,
    required this.onOpenMovie,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<CineClubeDetailCubit, CineClubeDetailState>(
        builder: (context, state) => switch (state) {
          CineClubeDetailLoading() => const Center(
            child: MuuvieActivityIndicator(),
          ),
          CineClubeDetailError() => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          final CineClubeDetailSuccess success => DefaultTabController(
            length: 3,
            child: Column(
              children: [
                _Header(
                  state: success,
                  onJoin: onJoin,
                  onLeave: onLeave,
                  onEdit: onEdit,
                  onCancel: onCancel,
                ),
                if (success.cineclube.isCycle)
                  _SessionPicker(
                    state: success,
                    onSelected: cubit.selectSession,
                  ),
                MuuvieTabBar(
                  tabs: [
                    l10n?.maratonaTabAbout ?? '',
                    l10n?.cineclubeTabProgress ?? '',
                    l10n?.cineclubeTabParticipants ?? '',
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MuuvieKeepAliveTab(
                        child: CineClubeAboutTab(
                          cineclube: success.cineclube,
                          session: success.session,
                          onOpenUser: onOpenUser,
                          onOpenMovie: onOpenMovie,
                          onOpenLink: onOpenLink,
                        ),
                      ),
                      CineClubeProgressTab(
                        key: ValueKey('progress-${success.session?.id}'),
                        cineclube: success.cineclube,
                        session: success.session,
                        onOpenUser: onOpenUser,
                      ),
                      CineClubeParticipantsTab(
                        key: ValueKey('participants-${success.session?.id}'),
                        cineclube: success.cineclube,
                        session: success.session,
                        onOpenUser: onOpenUser,
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
  final CineClubeDetailSuccess state;
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
    final cineclube = state.cineclube;
    final me = cineclube.me;
    final current = cineclube.currentSession;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CineClubePoster(
                posterPath: current?.movie.posterPath,
                accentColor: cineclube.accentColor,
                width: 64,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        cineclube.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      cineclubePeriod(
                        l10n,
                        cineclube.startsOn,
                        cineclube.endsOn,
                      ),
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
                          label: cineclube.status.label(l10n),
                          highlighted:
                              cineclube.status == CineClubeStatus.active,
                        ),
                        MaratonaBadge(
                          label:
                              l10n?.maratonaParticipants(
                                cineclube.totalParticipants,
                              ) ??
                              '',
                          icon: Icons.people_outline,
                        ),
                        if (cineclube.isCycle)
                          MaratonaBadge(
                            label:
                                l10n?.cineclubeSessionsCount(
                                  cineclube.sessions.length,
                                ) ??
                                '',
                            icon: Icons.repeat,
                          ),
                        if (cineclube.hasPassword)
                          MaratonaBadge(
                            label: l10n?.maratonaLocked ?? '',
                            icon: Icons.lock_outline,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (cineclube.canEdit && cineclube.status.open)
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
                      child: Text(l10n?.cineclubeCancel ?? ''),
                    ),
                  ],
                ),
            ],
          ),
          if (me != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  me.progress.icon,
                  size: 20,
                  color: cineclubeColor(context, cineclube.accentColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cineclube.isCycle
                        ? '${me.progress.label(l10n)} · '
                              '${l10n?.cineclubeCompletedSessions(me.completedSessions, cineclube.sessions.length) ?? ''}'
                        : me.progress.label(l10n),
                    style: textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
          if (cineclube.status.open) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: me == null
                  ? FilledButton.icon(
                      onPressed: state.busy ? null : onJoin,
                      icon: const Icon(Icons.groups_outlined),
                      label: Text(l10n?.cineclubeJoin ?? ''),
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

/// The movies of a cycle (F8.6): picking one shows its progress and
/// participants.
class _SessionPicker extends StatelessWidget {
  final CineClubeDetailSuccess state;
  final ValueChanged<int> onSelected;

  const _SessionPicker({required this.state, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final selected = state.session?.id;
    final current = state.cineclube.currentSessionId;
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final (index, session) in state.cineclube.sessions.indexed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: session.id == current
                    ? const Icon(Icons.play_arrow, size: 16)
                    : null,
                label: Text(
                  l10n?.cineclubeSessionLabel(index + 1, session.movie.title) ??
                      session.movie.title,
                ),
                selected: session.id == selected,
                onSelected: (_) => onSelected(session.id),
              ),
            ),
        ],
      ),
    );
  }
}
