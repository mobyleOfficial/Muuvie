import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_ui/follows/follow_button.dart';
import 'package:profile_ui/follows/follows_bloc.dart';
import 'package:profile_ui/follows/follows_state.dart';
import 'package:social_network/social_network.dart';

/// "Seguidores" and "Seguindo" of a profile (F6.3), in two tabs.
class FollowsScreen extends StatelessWidget {
  final FollowsCubit cubit;
  final FollowList initialList;
  final ValueChanged<SocialUser> onOpenProfile;
  final ValueChanged<FollowCard> onToggleFollow;

  const FollowsScreen({
    super.key,
    required this.cubit,
    required this.initialList,
    required this.onOpenProfile,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: DefaultTabController(
        length: 2,
        initialIndex: FollowList.values.indexOf(initialList),
        child: Column(
          children: [
            MuuvieTabBar(
              tabs: [
                l10n?.profileFollowersTitle ?? '',
                l10n?.profileFollowingTitle ?? '',
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final list in FollowList.values)
                    MuuvieKeepAliveTab(
                      child: BlocBuilder<FollowsCubit, FollowsState>(
                        buildWhen: (previous, current) =>
                            previous.of(list) != current.of(list),
                        builder: (context, state) => _List(
                          list: list,
                          state: state.of(list),
                          cubit: cubit,
                          onOpenProfile: onOpenProfile,
                          onToggleFollow: onToggleFollow,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  final FollowList list;
  final FollowListState state;
  final FollowsCubit cubit;
  final ValueChanged<SocialUser> onOpenProfile;
  final ValueChanged<FollowCard> onToggleFollow;

  const _List({
    required this.list,
    required this.state,
    required this.cubit,
    required this.onOpenProfile,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (state) {
      FollowListLoading() => const Center(child: CircularProgressIndicator()),
      FollowListError() => MuuvieEmptyState(
        title: l10n?.emptyStateErrorTitle ?? '',
        message: l10n?.emptyStateErrorMessage ?? '',
        action: () => cubit.refresh(list),
        actionLabel: l10n?.emptyStateRetry ?? '',
      ),
      FollowListSuccess(:final cards) when cards.isEmpty => MuuvieEmptyState(
        title: l10n?.emptyStateNoItemsTitle ?? '',
        message: list == FollowList.followers
            ? l10n?.followsEmptyFollowers ?? ''
            : l10n?.followsEmptyFollowing ?? '',
      ),
      final FollowListSuccess success => RefreshIndicator(
        onRefresh: () => cubit.refresh(list),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 400) cubit.loadMore(list);
            return false;
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: success.cards.length + (success.hasNext ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == success.cards.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final card = success.cards[index];
              return _Row(
                card: card,
                busy: success.busy.contains(card.user.id),
                onOpen: () => onOpenProfile(card.user),
                onToggleFollow: () => onToggleFollow(card),
              );
            },
          ),
        ),
      ),
    };
  }
}

class _Row extends StatelessWidget {
  final FollowCard card;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onToggleFollow;

  const _Row({
    required this.card,
    required this.busy,
    required this.onOpen,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final user = card.user;
    final handle = user.handle;
    final subtitle = [
      if (handle != null) '@$handle',
      if (card.status.followedBy && !card.self) l10n?.profileFollowsYou ?? '',
    ].join(' · ');

    return ListTile(
      onTap: onOpen,
      leading: MuuvieUserAvatar(
        url: user.avatarUrl,
        name: user.name,
        accentColor: user.accentColor,
      ),
      title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
      trailing: card.self
          ? null
          : FollowButton(
              following: card.status.following,
              followedBy: card.status.followedBy,
              busy: busy,
              onPressed: onToggleFollow,
            ),
    );
  }
}

/// Text for a failed follow: the rate limit has its own message.
String followErrorMessage(AppLocalizations? l10n, AppError error) =>
    error == AppError.tooManyRequests
    ? l10n?.followRateLimited ?? ''
    : l10n?.followError ?? '';
