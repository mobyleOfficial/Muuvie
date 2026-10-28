import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:profile_ui/tabs/charts/charts_bloc.dart';
import 'package:profile_ui/tabs/charts/charts_screen.dart';
import 'package:stats/stats.dart';

/// The Gráficos tab (F9.2). [userId] is `me` on my profile, where the goal
/// can be set and the retrospective opens (F9.3, F9.4).
class ChartsPage extends StatefulWidget {
  final String userId;

  const ChartsPage({super.key, required this.userId});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  late final ChartsCubit _cubit = ChartsCubit(
    userId: widget.userId,
    getYears: GetIt.I<GetStatsYears>(),
    getYearStats: GetIt.I<GetYearStats>(),
    getCalendar: GetIt.I<GetStatsCalendar>(),
    getGoal: GetIt.I<GetYearlyGoal>(),
    setGoal: GetIt.I<SetYearlyGoal>(),
  )..load();

  bool get _isSelf => widget.userId == 'me';

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _editGoal(YearlyGoal? goal) async {
    final l10n = AppLocalizations.of(context);
    final value = await MuuvieTextPromptDialog.show(
      context,
      title: l10n?.chartsGoalTitle ?? '',
      confirmLabel: l10n?.chartsGoalSave ?? '',
      initialValue: goal?.targetMovies.toString(),
      hintText: '100',
      keyboardType: TextInputType.number,
      errorText: l10n?.chartsGoalInvalid,
      parse: (text) {
        final number = int.tryParse(text.trim());
        return number != null && number >= 1 && number <= 5000
            ? '$number'
            : null;
      },
    );
    if (value == null || !mounted) return;
    final error = await _cubit.setGoal(int.parse(value));
    if (error != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n?.maratonaActionError ?? '')));
    }
  }

  @override
  Widget build(BuildContext context) => ChartsScreen(
    cubit: _cubit,
    isSelf: _isSelf,
    onEditGoal: _isSelf ? _editGoal : null,
    onRemoveGoal: _isSelf ? () => _cubit.setGoal(null) : null,
    onOpenRetrospective: _isSelf
        ? (year) => context.router.root.push(RetrospectiveRoute(year: year))
        : null,
  );
}
