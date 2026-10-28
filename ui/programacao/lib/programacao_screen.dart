import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:maratonas/maratonas.dart';
import 'package:programacao/cineclubes/cineclube_list.dart';
import 'package:programacao/maratonas/maratona_list.dart';
import 'package:programacao/programacao_bloc.dart';
import 'package:programacao/programacao_state.dart';

class ProgramacaoScreen extends StatelessWidget {
  final ProgramacaoCubit cubit;
  final GlobalKey<MaratonaListViewState> maratonaListKey;
  final GlobalKey<CineClubeListViewState> cineclubeListKey;
  final ValueChanged<MaratonaSummary> onOpenMaratona;
  final VoidCallback onCreateMaratona;
  final ValueChanged<CineClubeSummary> onOpenCineClube;
  final VoidCallback onCreateCineClube;

  /// Turning "Participando" on asks for an account first.
  final ValueChanged<bool> onParticipatingChanged;

  const ProgramacaoScreen({
    super.key,
    required this.cubit,
    required this.maratonaListKey,
    required this.cineclubeListKey,
    required this.onOpenMaratona,
    required this.onCreateMaratona,
    required this.onCreateCineClube,
    required this.onOpenCineClube,
    required this.onParticipatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ProgramacaoCubit, ProgramacaoState>(
        builder: (context, state) => switch (state) {
          ProgramacaoLoading() => const Center(
            child: MuuvieActivityIndicator(),
          ),
          ProgramacaoError(:final message) => MuuvieEmptyState(
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
          ),
          ProgramacaoSuccess(:final participatingOnly) => DefaultTabController(
            length: 2,
            child: Column(
              children: [
                MuuvieTabBar(
                  tabs: [
                    l10n?.programacaoMaratonasTab ?? '',
                    l10n?.programacaoCineClubesTab ?? '',
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilterChip(
                      label: Text(l10n?.programacaoParticipatingFilter ?? ''),
                      selected: participatingOnly,
                      onSelected: onParticipatingChanged,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MaratonaList(
                        key: maratonaListKey,
                        participating: participatingOnly,
                        onOpen: onOpenMaratona,
                        onCreate: onCreateMaratona,
                      ),
                      CineClubeList(
                        key: cineclubeListKey,
                        participating: participatingOnly,
                        onOpen: onOpenCineClube,
                        onCreate: onCreateCineClube,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
