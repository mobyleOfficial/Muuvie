import 'package:social/social_bloc.dart';
import 'package:social/social_state.dart';
import 'package:social/tabs/activities/activities_bloc.dart';
import 'package:social/tabs/activities/activities_screen.dart';
import 'package:social/tabs/friends/friends_cubit.dart';
import 'package:social/tabs/friends/friends_screen.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialScreen extends StatelessWidget {
  final SocialCubit cubit;
  final ActivitiesCubit activitiesCubit;
  final FriendsCubit friendsCubit;

  const SocialScreen({
    super.key,
    required this.cubit,
    required this.activitiesCubit,
    required this.friendsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<SocialCubit, SocialState>(
        builder: (context, state) => switch (state) {
          SocialLoading() => const Center(child: CircularProgressIndicator()),
          SocialError() => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: state.message,
            action: cubit.reload,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          SocialSuccess() => _SocialContent(
            activitiesCubit: activitiesCubit,
            friendsCubit: friendsCubit,
          ),
        },
      ),
    );
  }
}

class _SocialContent extends StatelessWidget {
  final ActivitiesCubit activitiesCubit;
  final FriendsCubit friendsCubit;

  const _SocialContent({
    required this.activitiesCubit,
    required this.friendsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          MuuvieTabBar(
            tabs: [
              l10n?.socialFriendsTab ?? '',
              l10n?.socialActivitiesTab ?? '',
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MuuvieKeepAliveTab(child: FriendsScreen(cubit: friendsCubit)),
                MuuvieKeepAliveTab(
                  child: ActivitiesScreen(cubit: activitiesCubit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
