import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social/feed/activity_card.dart';
import 'package:social/social_bloc.dart';
import 'package:social/social_state.dart';
import 'package:social_network/social_network.dart';

/// The Atts tab (F6.2): scope filter on top, then the feed, refreshed by
/// pulling and extended by scrolling.
class SocialScreen extends StatelessWidget {
  final SocialCubit cubit;
  final ValueChanged<SocialUser> onOpenProfile;
  final ValueChanged<ActivityMovie> onOpenMovie;
  final ValueChanged<ActivityShelf> onOpenShelf;
  final ValueChanged<ActivityLocadora> onOpenLocadora;
  final ValueChanged<ActivityMaratona> onOpenMaratona;
  final ValueChanged<ActivityCineClube> onOpenCineClube;
  final ValueChanged<Activity> onToggleHidden;

  const SocialScreen({
    super.key,
    required this.cubit,
    required this.onOpenProfile,
    required this.onOpenMovie,
    required this.onOpenShelf,
    required this.onOpenLocadora,
    required this.onOpenMaratona,
    required this.onOpenCineClube,
    required this.onToggleHidden,
  });

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) => Column(
        children: [
          _ScopeFilter(selected: state.scope, onSelected: cubit.selectScope),
          Expanded(
            child: switch (state) {
              SocialLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              SocialError() => _Error(onRetry: cubit.refresh),
              SocialSuccess() => _Feed(
                state: state,
                cubit: cubit,
                onOpenProfile: onOpenProfile,
                onOpenMovie: onOpenMovie,
                onOpenShelf: onOpenShelf,
                onOpenLocadora: onOpenLocadora,
                onOpenMaratona: onOpenMaratona,
                onOpenCineClube: onOpenCineClube,
                onToggleHidden: onToggleHidden,
              ),
            },
          ),
        ],
      ),
    ),
  );
}

class _ScopeFilter extends StatelessWidget {
  final FeedScope selected;
  final ValueChanged<FeedScope> onSelected;

  const _ScopeFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      FeedScope.all: l10n?.attsScopeAll ?? '',
      FeedScope.following: l10n?.attsScopeFollowing ?? '',
      FeedScope.me: l10n?.attsScopeMe ?? '',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          for (final scope in FeedScope.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(labels[scope]!),
                selected: scope == selected,
                onSelected: (_) => onSelected(scope),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  final SocialSuccess state;
  final SocialCubit cubit;
  final ValueChanged<SocialUser> onOpenProfile;
  final ValueChanged<ActivityMovie> onOpenMovie;
  final ValueChanged<ActivityShelf> onOpenShelf;
  final ValueChanged<ActivityLocadora> onOpenLocadora;
  final ValueChanged<ActivityMaratona> onOpenMaratona;
  final ValueChanged<ActivityCineClube> onOpenCineClube;
  final ValueChanged<Activity> onToggleHidden;

  const _Feed({
    required this.state,
    required this.cubit,
    required this.onOpenProfile,
    required this.onOpenMovie,
    required this.onOpenShelf,
    required this.onOpenLocadora,
    required this.onOpenMaratona,
    required this.onOpenCineClube,
    required this.onToggleHidden,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activities = state.activities;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: activities.isEmpty
          ? LayoutBuilder(
              // Scrollable even when empty, so pulling still refreshes.
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: MuuvieEmptyState(
                    illustration: MuuvieIllustration.sleeping,
                    title: l10n?.attsEmptyTitle ?? '',
                    message: state.scope == FeedScope.me
                        ? l10n?.attsEmptyMe ?? ''
                        : l10n?.attsEmptyFollowing ?? '',
                  ),
                ),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 600) cubit.loadMore();
                return false;
              },
              child: ListView.builder(
                // One scroll position per scope, kept while switching.
                key: PageStorageKey(state.scope),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: activities.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == activities.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final activity = activities[index];
                  return ActivityCard(
                    key: ValueKey(activity.id),
                    activity: activity,
                    onOpenActor: () => onOpenProfile(activity.actor),
                    onOpenMovie: onOpenMovie,
                    onOpenShelf: onOpenShelf,
                    onOpenLocadora: onOpenLocadora,
                    onOpenMaratona: onOpenMaratona,
                    onOpenCineClube: onOpenCineClube,
                    onToggleLove: () => cubit.toggleLove(activity),
                    onToggleHidden: activity.self
                        ? () => onToggleHidden(activity)
                        : null,
                  );
                },
              ),
            ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;

  const _Error({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MuuvieEmptyState(
      illustration: MuuvieIllustration.error,
      title: l10n?.emptyStateErrorTitle ?? '',
      message: l10n?.emptyStateErrorMessage ?? '',
      action: onRetry,
      actionLabel: l10n?.emptyStateRetry ?? '',
    );
  }
}
