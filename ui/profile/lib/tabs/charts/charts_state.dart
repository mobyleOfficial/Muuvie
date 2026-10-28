import 'package:stats/stats.dart';

sealed class ChartsState {
  const ChartsState();
}

class ChartsLoading extends ChartsState {
  const ChartsLoading();
}

/// The charts of [year] (F9.2) with the year picker, the calendar and the
/// goal (F9.4). [years] are the ones with sessions; [loadingYear] is true
/// while another year loads.
class ChartsSuccess extends ChartsState {
  final List<int> years;
  final int year;
  final YearStats stats;
  final List<CalendarDay> calendar;
  final YearlyGoal? goal;
  final bool loadingYear;

  const ChartsSuccess({
    required this.years,
    required this.year,
    required this.stats,
    this.calendar = const [],
    this.goal,
    this.loadingYear = false,
  });

  ChartsSuccess copyWith({
    int? year,
    YearStats? stats,
    List<CalendarDay>? calendar,
    YearlyGoal? goal,
    bool clearGoal = false,
    bool? loadingYear,
  }) => ChartsSuccess(
    years: years,
    year: year ?? this.year,
    stats: stats ?? this.stats,
    calendar: calendar ?? this.calendar,
    goal: clearGoal ? null : goal ?? this.goal,
    loadingYear: loadingYear ?? this.loadingYear,
  );
}

class ChartsError extends ChartsState {
  final String message;

  const ChartsError(this.message);
}
