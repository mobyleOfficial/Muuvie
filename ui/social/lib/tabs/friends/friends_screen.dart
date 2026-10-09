import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:public_profile_domain/models/following_user.dart';
import 'package:social/tabs/friends/friends_cubit.dart';
import 'package:social/tabs/friends/friends_state.dart';

class FriendsScreen extends StatelessWidget {
  final FriendsCubit cubit;

  const FriendsScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<FriendsCubit, FriendsState>(
        builder: (context, state) => switch (state) {
          FriendsLoading() => const Center(child: CircularProgressIndicator()),
          FriendsError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          FriendsSuccess(:final users) when users.isEmpty => Center(
            child: Text(l10n?.socialNoFriends ?? 'No friends yet'),
          ),
          FriendsSuccess(:final users) => _FriendsList(users: users),
        },
      ),
    );
  }
}

class _FriendsList extends StatelessWidget {
  final List<FollowingUser> users;

  const _FriendsList({required this.users});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, indent: 72, color: colorScheme.outlineVariant),
      itemBuilder: (context, index) => _FriendTile(user: users[index]),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final FollowingUser user;

  const _FriendTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<FriendsCubit>();

    return Semantics(
      label: '${user.displayName}, ${user.moviesWatchedCount} movies watched',
      button: true,
      child: ListTile(
        onTap: () => context.router.push(PublicProfileRoute(userId: user.id)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: ExcludeSemantics(
          child: CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
              user.initials,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          user.displayName,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${user.moviesWatchedCount} movies watched',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: _FollowButton(
          user: user,
          onToggle: () => cubit.toggleFollow(user),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final FollowingUser user;
  final VoidCallback onToggle;

  const _FollowButton({required this.user, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFollowing = user.isFollowing;

    return Semantics(
      button: true,
      label: isFollowing ? 'Unfollow' : 'Follow',
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isFollowing
                ? colorScheme.surfaceContainerHighest
                : colorScheme.secondary,
            borderRadius: BorderRadius.circular(50),
            border: isFollowing
                ? Border.all(color: colorScheme.outlineVariant)
                : null,
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              color: isFollowing
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
