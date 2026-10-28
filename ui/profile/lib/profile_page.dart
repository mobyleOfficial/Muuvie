import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:profile/profile.dart';
import 'package:profile_ui/member/member_profile_view.dart';

/// Root of the Perfil tab: my own profile.
@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // The legacy profile stream follows the imports over the WebSocket; the
  // header reloads when the import state or the watched count changes.
  late final Stream<Object?> _changes = GetIt.I<ObserveUserProfile>()()
      .map((profile) => (profile.isScraping, profile.moviesWatchedCount))
      .distinct()
      .skip(1);

  @override
  Widget build(BuildContext context) =>
      MemberProfileView(userId: 'me', changes: _changes);
}
