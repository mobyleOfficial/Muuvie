import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification_ui/missions/missions_bloc.dart';
import 'package:gamification_ui/missions/missions_state.dart';
import 'package:gamification_ui/widgets/gamification_labels.dart';
import 'package:intl/intl.dart';

/// Three missions a week, the same for everyone, that give XP to the
/// pinned bichinho.
class MissionsScreen extends StatelessWidget {
  final MissionsCubit cubit;

  const MissionsScreen({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MissionsCubit, MissionsState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        MissionsLoading() => const Center(child: MuuvieActivityIndicator()),
        MissionsError() => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: l10n?.emptyStateErrorMessage ?? '',
          action: cubit.load,
          actionLabel: l10n?.emptyStateRetry ?? '',
        ),
        MissionsSuccess(:final week) => RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n?.missionsWeek(
                      DateFormat.MMMd(
                        Intl.getCurrentLocale(),
                      ).format(week.weekStart),
                      DateFormat.MMMd(
                        Intl.getCurrentLocale(),
                      ).format(week.weekEnd),
                    ) ??
                    '',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n?.missionsHelp ?? '', style: textTheme.bodySmall),
              const SizedBox(height: 16),
              for (final mission in week.missions)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                mission.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: mission.completed
                                    ? colorScheme.primary
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  missionText(l10n, mission),
                                  style: textTheme.titleSmall,
                                ),
                              ),
                              Text(
                                l10n?.missionXp(mission.xp) ?? '',
                                style: textTheme.labelLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: mission.fraction,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.completed
                                ? l10n?.missionDone ?? ''
                                : '${mission.progress}/${mission.target}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      },
    );
  }
}
