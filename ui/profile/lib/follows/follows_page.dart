import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:profile_ui/follows/follows_bloc.dart';
import 'package:profile_ui/follows/follows_screen.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:social_network/social_network.dart';

/// Followers and following of a profile (F6.3). The title comes from
/// [profileName] through the route title resolver.
@RoutePage()
class FollowsPage extends StatefulWidget {
  /// The owner, or `me` for the current user.
  final String userId;
  final String profileName;
  final FollowList initialList;

  const FollowsPage({
    super.key,
    this.userId = 'me',
    required this.profileName,
    this.initialList = FollowList.followers,
  });

  @override
  State<FollowsPage> createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  late final FollowsCubit _cubit = FollowsCubit(
    userId: widget.userId,
    getFollowList: GetIt.I<GetFollowList>(),
    setFollowing: GetIt.I<SetFollowing>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _toggleFollow(FollowCard card) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final error = await _cubit.toggleFollow(card);
    if (!mounted || error == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(followErrorMessage(l10n, error))),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FollowsScreen(
      cubit: _cubit,
      initialList: widget.initialList,
      onOpenProfile: (user) => context.router.push(
        PublicProfileRoute(userId: user.id, displayName: user.name),
      ),
      onToggleFollow: _toggleFollow,
    ),
  );
}
