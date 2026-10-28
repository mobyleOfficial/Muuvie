import 'package:auto_route/auto_route.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:programacao/cineclubes/cineclube_list.dart';
import 'package:programacao/maratonas/maratona_list.dart';
import 'package:programacao/programacao_bloc.dart';
import 'package:programacao/programacao_screen.dart';

/// Root of the Programação tab: Maratonas | CineClubes, like a cinema schedule.
@RoutePage()
class ProgramacaoPage extends StatefulWidget {
  const ProgramacaoPage({super.key});

  @override
  State<ProgramacaoPage> createState() => _ProgramacaoPageState();
}

class _ProgramacaoPageState extends State<ProgramacaoPage> {
  late final ProgramacaoCubit _cubit = ProgramacaoCubit()..load();
  final _maratonaListKey = GlobalKey<MaratonaListViewState>();
  final _cineclubeListKey = GlobalKey<CineClubeListViewState>();

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _setParticipating(bool participating) async {
    if (participating && !await AuthGate.check(context)) return;
    _cubit.setParticipatingOnly(participating);
  }

  Future<void> _createMaratona() async {
    if (!await AuthGate.check(context) || !mounted) return;
    await context.router.push(MaratonaEditorRoute());
    _maratonaListKey.currentState?.reload();
  }

  Future<void> _createCineClube() async {
    if (!await AuthGate.check(context) || !mounted) return;
    await context.router.push(CineClubeEditorRoute());
    _cineclubeListKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) => ProgramacaoScreen(
    cubit: _cubit,
    maratonaListKey: _maratonaListKey,
    cineclubeListKey: _cineclubeListKey,
    onOpenCineClube: (cineclube) async {
      await context.router.push(
        CineClubeDetailRoute(slug: cineclube.slug, title: cineclube.title),
      );
      _cineclubeListKey.currentState?.reload();
    },
    onCreateCineClube: _createCineClube,
    onOpenMaratona: (maratona) async {
      await context.router.push(
        MaratonaDetailRoute(slug: maratona.slug, title: maratona.title),
      );
      _maratonaListKey.currentState?.reload();
    },
    onCreateMaratona: _createMaratona,
    onParticipatingChanged: _setParticipating,
  );
}
