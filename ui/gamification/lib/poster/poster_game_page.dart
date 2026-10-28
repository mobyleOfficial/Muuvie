import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/poster/poster_game_bloc.dart';
import 'package:gamification_ui/poster/poster_game_screen.dart';
import 'package:get_it/get_it.dart';

/// The poster game (F10.5) over the whole screen.
@RoutePage()
class PosterGamePage extends StatefulWidget {
  const PosterGamePage({super.key});

  @override
  State<PosterGamePage> createState() => _PosterGamePageState();
}

class _PosterGamePageState extends State<PosterGamePage> {
  late final PosterGameCubit _cubit = PosterGameCubit(
    getRound: GetIt.I<GetPosterRound>(),
  )..next();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MuuvieModalScreen(
    title: AppLocalizations.of(context)?.posterGameTitle,
    backgroundColor: Theme.of(context).colorScheme.surface,
    foregroundColor: Theme.of(context).colorScheme.onSurface,
    onClose: () => context.router.maybePop(),
    body: PosterGameScreen(cubit: _cubit),
  );
}
