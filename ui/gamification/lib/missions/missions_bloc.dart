import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/missions/missions_state.dart';

/// The missions of the week (F10.2).
class MissionsCubit extends Cubit<MissionsState> {
  final GetMissions _getMissions;

  MissionsCubit({required GetMissions getMissions})
    : _getMissions = getMissions,
      super(const MissionsLoading());

  Future<void> load() async {
    final result = await _getMissions();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => MissionsSuccess(data),
      Failure() => const MissionsError(),
    });
  }
}
