import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/widgets/maratona_card.dart';

import 'package:profile_ui/tabs/participations/participations_bloc.dart';
import 'package:profile_ui/tabs/participations/participations_state.dart';

class ParticipationsScreen extends StatelessWidget {
  final ParticipationsCubit cubit;
  final ValueChanged<MaratonaSummary> onOpenMaratona;

  const ParticipationsScreen({
    super.key,
    required this.cubit,
    required this.onOpenMaratona,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ParticipationsCubit, ParticipationsState>(
        builder: (context, state) => switch (state) {
          ParticipationsLoading() => const Center(
            child: MuuvieActivityIndicator(),
          ),
          ParticipationsError(:final message) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: message,
            action: cubit.load,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          ParticipationsSuccess(:final maratonas) when maratonas.isEmpty =>
            MuuvieEmptyState(
              illustration: MuuvieIllustration.maratona,
              title: l10n?.profileTabParticipations ?? '',
              message: l10n?.maratonaParticipatingEmpty ?? '',
            ),
          final ParticipationsSuccess success =>
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 400) cubit.loadMore();
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: success.maratonas.length,
                itemBuilder: (context, index) => MaratonaCard(
                  maratona: success.maratonas[index],
                  onTap: () => onOpenMaratona(success.maratonas[index]),
                ),
              ),
            ),
        },
      ),
    );
  }
}
