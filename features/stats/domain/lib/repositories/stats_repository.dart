import 'package:core/core.dart';
import 'package:stats_domain/models/models.dart';

/// Charts, retrospective and yearly goals of the v1 API (B9). [userId] is a
/// user id or `me`; the charts count only what the current user may see.
abstract interface class StatsRepository {
  Future<Result<List<int>>> getYears(String userId);

  Future<Result<YearStats>> getYear(String userId, int year);

  Future<Result<List<CalendarDay>>> getCalendar(String userId, int year);

  Future<Result<List<RetrospectiveYear>>> getRetrospectiveYears();

  /// Fails with `notFound` when the year has no finished movie.
  Future<Result<Retrospective>> getRetrospective(int year);

  /// Fails with `notFound` when there is no goal for the year.
  Future<Result<YearlyGoal>> getGoal(String userId, int year);

  Future<Result<YearlyGoal>> setGoal(int year, int targetMovies);

  Future<Result<void>> removeGoal(int year);
}
