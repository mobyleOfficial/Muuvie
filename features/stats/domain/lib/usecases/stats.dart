import 'package:core/core.dart';
import 'package:stats_domain/models/models.dart';
import 'package:stats_domain/repositories/stats_repository.dart';

/// The years with sessions of a user, newest first (the year picker, F9.2).
class GetStatsYears extends UseCase<String, Result<List<int>>> {
  final StatsRepository _repository;

  GetStatsYears(this._repository);

  @override
  Future<Result<List<int>>> call([String? userId]) =>
      _repository.getYears(userId!);
}

class StatsYearParams {
  final String userId;
  final int year;

  const StatsYearParams({required this.userId, required this.year});
}

/// The charts of a year (F9.1, F9.2).
class GetYearStats extends UseCase<StatsYearParams, Result<YearStats>> {
  final StatsRepository _repository;

  GetYearStats(this._repository);

  @override
  Future<Result<YearStats>> call([StatsYearParams? params]) =>
      _repository.getYear(params!.userId, params.year);
}

/// Sessions per day of a year, for the heatmap (F9.2).
class GetStatsCalendar
    extends UseCase<StatsYearParams, Result<List<CalendarDay>>> {
  final StatsRepository _repository;

  GetStatsCalendar(this._repository);

  @override
  Future<Result<List<CalendarDay>>> call([StatsYearParams? params]) =>
      _repository.getCalendar(params!.userId, params.year);
}

class GetRetrospectiveYears
    extends UseCase<void, Result<List<RetrospectiveYear>>> {
  final StatsRepository _repository;

  GetRetrospectiveYears(this._repository);

  @override
  Future<Result<List<RetrospectiveYear>>> call([void params]) =>
      _repository.getRetrospectiveYears();
}

/// The current user's year in stories (F9.3).
class GetRetrospective extends UseCase<int, Result<Retrospective>> {
  final StatsRepository _repository;

  GetRetrospective(this._repository);

  @override
  Future<Result<Retrospective>> call([int? year]) =>
      _repository.getRetrospective(year!);
}

class GetYearlyGoal extends UseCase<StatsYearParams, Result<YearlyGoal>> {
  final StatsRepository _repository;

  GetYearlyGoal(this._repository);

  @override
  Future<Result<YearlyGoal>> call([StatsYearParams? params]) =>
      _repository.getGoal(params!.userId, params.year);
}

class SetYearlyGoalParams {
  final int year;

  /// Null removes the goal.
  final int? targetMovies;

  const SetYearlyGoalParams({required this.year, this.targetMovies});
}

/// Sets or removes the current user's goal (F9.4). Removing answers null.
class SetYearlyGoal extends UseCase<SetYearlyGoalParams, Result<YearlyGoal?>> {
  final StatsRepository _repository;

  SetYearlyGoal(this._repository);

  @override
  Future<Result<YearlyGoal?>> call([SetYearlyGoalParams? params]) async {
    final value = params!;
    final target = value.targetMovies;
    if (target == null) {
      return switch (await _repository.removeGoal(value.year)) {
        Success() => const Success(null),
        Failure(:final error) => Failure(error),
      };
    }
    return switch (await _repository.setGoal(value.year, target)) {
      Success(:final data) => Success(data),
      Failure(:final error) => Failure(error),
    };
  }
}
