import 'package:core/core.dart';
import 'package:stats_data/datasources/stats_remote_data_source.dart';
import 'package:stats_domain/models/models.dart';
import 'package:stats_domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource _remoteDataSource;

  StatsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<int>>> getYears(String userId) =>
      _remoteDataSource.getYears(userId);

  @override
  Future<Result<YearStats>> getYear(String userId, int year) =>
      _remoteDataSource.getYear(userId, year);

  @override
  Future<Result<List<CalendarDay>>> getCalendar(String userId, int year) =>
      _remoteDataSource.getCalendar(userId, year);

  @override
  Future<Result<List<RetrospectiveYear>>> getRetrospectiveYears() =>
      _remoteDataSource.getRetrospectiveYears();

  @override
  Future<Result<Retrospective>> getRetrospective(int year) =>
      _remoteDataSource.getRetrospective(year);

  @override
  Future<Result<YearlyGoal>> getGoal(String userId, int year) =>
      _remoteDataSource.getGoal(userId, year);

  @override
  Future<Result<YearlyGoal>> setGoal(int year, int targetMovies) =>
      _remoteDataSource.setGoal(year, targetMovies);

  @override
  Future<Result<void>> removeGoal(int year) =>
      _remoteDataSource.removeGoal(year);
}
