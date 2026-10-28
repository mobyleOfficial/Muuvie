import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/missions/missions_bloc.dart';
import 'package:gamification_ui/missions/missions_screen.dart';
import 'package:get_it/get_it.dart';

/// The weekly missions (F10.2), over the whole screen.
@RoutePage()
class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  late final MissionsCubit _cubit = MissionsCubit(
    getMissions: GetIt.I<GetMissions>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MuuvieModalScreen(
    title: AppLocalizations.of(context)?.missionsTitle,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    onClose: () => context.router.maybePop(),
    body: MissionsScreen(cubit: _cubit),
  );
}
