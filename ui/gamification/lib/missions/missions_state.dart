import 'package:gamification/gamification.dart';

sealed class MissionsState {
  const MissionsState();
}

class MissionsLoading extends MissionsState {
  const MissionsLoading();
}

class MissionsError extends MissionsState {
  const MissionsError();
}

class MissionsSuccess extends MissionsState {
  final MissionWeek week;

  const MissionsSuccess(this.week);
}
