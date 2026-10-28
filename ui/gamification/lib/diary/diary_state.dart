import 'package:gamification/gamification.dart';
import 'package:stats/stats.dart';

sealed class DiaryState {
  const DiaryState();
}

class DiaryLoading extends DiaryState {
  const DiaryLoading();
}

class DiaryError extends DiaryState {
  const DiaryError();
}

/// A day being written. [day] holds the edits; [dirty] is true until they
/// are saved. [month] are the written days of the month, for the calendar
/// strip, and [goal] the yearly goal (F9.4), shown here too.
class DiaryReady extends DiaryState {
  final DiaryDay day;
  final bool dirty;
  final bool saving;
  final List<DiaryDaySummary> month;
  final YearlyGoal? goal;

  const DiaryReady({
    required this.day,
    this.dirty = false,
    this.saving = false,
    this.month = const [],
    this.goal,
  });

  DiaryReady copyWith({
    DiaryDay? day,
    bool? dirty,
    bool? saving,
    List<DiaryDaySummary>? month,
  }) => DiaryReady(
    day: day ?? this.day,
    dirty: dirty ?? this.dirty,
    saving: saving ?? this.saving,
    month: month ?? this.month,
    goal: goal,
  );
}
