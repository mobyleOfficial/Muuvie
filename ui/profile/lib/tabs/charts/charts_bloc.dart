import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_ui/tabs/charts/charts_state.dart';
import 'package:stats/stats.dart';

/// The Gráficos tab of a profile (F9.2): the years with sessions, the charts
/// of the picked one, its calendar and the yearly goal (F9.4).
class ChartsCubit extends Cubit<ChartsState> {
  final String userId;
  final GetStatsYears _getYears;
  final GetYearStats _getYearStats;
  final GetStatsCalendar _getCalendar;
  final GetYearlyGoal _getGoal;
  final SetYearlyGoal _setGoal;
  final DateTime Function() _now;

  ChartsCubit({
    required this.userId,
    required GetStatsYears getYears,
    required GetYearStats getYearStats,
    required GetStatsCalendar getCalendar,
    required GetYearlyGoal getGoal,
    required SetYearlyGoal setGoal,
    DateTime Function()? now,
  }) : _getYears = getYears,
       _getYearStats = getYearStats,
       _getCalendar = getCalendar,
       _getGoal = getGoal,
       _setGoal = setGoal,
       _now = now ?? DateTime.now,
       super(const ChartsLoading());

  int get currentYear => _now().year;

  Future<void> load() async {
    emit(const ChartsLoading());
    final years = await _getYears(userId);
    if (isClosed) return;
    switch (years) {
      case Failure(:final error):
        emit(ChartsError(error.message));
      case Success(:final data):
        // The current year comes first even without sessions: its goal lives there.
        final all = {currentYear, ...data}.toList()
          ..sort((a, b) => b.compareTo(a));
        await _show(
          all,
          data.contains(currentYear) || data.isEmpty ? currentYear : data.first,
        );
    }
  }

  Future<void> selectYear(int year) async {
    final current = state;
    if (current is! ChartsSuccess || current.year == year) return;
    emit(current.copyWith(loadingYear: true));
    await _show(current.years, year);
  }

  /// Sets the goal of the shown year, or removes it with null. Answers the error.
  Future<AppError?> setGoal(int? targetMovies) async {
    final current = state;
    if (current is! ChartsSuccess) return null;
    final result = await _setGoal(
      SetYearlyGoalParams(year: current.year, targetMovies: targetMovies),
    );
    if (isClosed) return null;
    final latest = state;
    if (latest is! ChartsSuccess) return null;
    switch (result) {
      case Failure(:final error):
        return error;
      case Success(:final data):
        emit(latest.copyWith(goal: data, clearGoal: data == null));
        return null;
    }
  }

  Future<void> _show(List<int> years, int year) async {
    final params = StatsYearParams(userId: userId, year: year);
    final results = await Future.wait([
      _getYearStats(params),
      _getCalendar(params),
      _getGoal(params),
    ]);
    if (isClosed) return;
    final stats = results[0] as Result<YearStats>;
    final calendar = results[1] as Result<List<CalendarDay>>;
    final goal = results[2] as Result<YearlyGoal>;
    switch (stats) {
      case Failure(:final error):
        emit(ChartsError(error.message));
      case Success(:final data):
        emit(
          ChartsSuccess(
            years: years,
            year: year,
            stats: data,
            calendar: switch (calendar) {
              Success(data: final days) => days,
              Failure() => const [],
            },
            goal: switch (goal) {
              Success(data: final value) => value,
              Failure() => null,
            },
          ),
        );
    }
  }
}
