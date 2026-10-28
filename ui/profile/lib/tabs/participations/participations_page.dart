import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/maratonas_router.dart';

import 'package:profile_ui/tabs/participations/participations_bloc.dart';
import 'package:profile_ui/tabs/participations/participations_screen.dart';

/// Maratonas a profile joined (phase 7). [userId] is the owner, or `me`.
class ParticipationsPage extends StatefulWidget {
  final String userId;

  const ParticipationsPage({super.key, required this.userId});

  @override
  State<ParticipationsPage> createState() => _ParticipationsPageState();
}

class _ParticipationsPageState extends State<ParticipationsPage> {
  late final ParticipationsCubit _cubit = ParticipationsCubit(
    userId: widget.userId,
    getMaratonas: GetIt.I<GetMaratonas>(),
  )..load();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ParticipationsScreen(
    cubit: _cubit,
    onOpenMaratona: (maratona) async {
      await context.router.push(
        MaratonaDetailRoute(slug: maratona.slug, title: maratona.title),
      );
      _cubit.load();
    },
  );
}
