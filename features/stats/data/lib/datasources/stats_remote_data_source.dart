import 'package:core/core.dart';
import 'package:stats_data/models/remote_stats.dart';
import 'package:stats_domain/models/models.dart';

abstract interface class StatsRemoteDataSource {
  Future<Result<List<int>>> getYears(String userId);

  Future<Result<YearStats>> getYear(String userId, int year);

  Future<Result<List<CalendarDay>>> getCalendar(String userId, int year);

  Future<Result<List<RetrospectiveYear>>> getRetrospectiveYears();

  Future<Result<Retrospective>> getRetrospective(int year);

  Future<Result<YearlyGoal>> getGoal(String userId, int year);

  Future<Result<YearlyGoal>> setGoal(int year, int targetMovies);

  Future<Result<void>> removeGoal(int year);
}

/// Chart, retrospective and goal endpoints of the v1 API (`/api/v1`).
class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  static const _base = '/api/v1/users';

  final HttpClient _httpClient;

  StatsRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<List<int>>> getYears(String userId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('${_user(userId)}/stats/years'),
    RemoteStats.years,
  );

  @override
  Future<Result<YearStats>> getYear(String userId, int year) async => _map(
    await _httpClient.get<Map<String, dynamic>>('${_user(userId)}/stats/$year'),
    RemoteStats.year,
  );

  @override
  Future<Result<List<CalendarDay>>> getCalendar(
    String userId,
    int year,
  ) async => switch (await _httpClient.get<List<dynamic>>(
    '${_user(userId)}/stats/$year/calendar',
  )) {
    Success(:final data) => Success(RemoteStats.calendar(data)),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<List<RetrospectiveYear>>> getRetrospectiveYears() async =>
      switch (await _httpClient.get<List<dynamic>>(
        '$_base/me/retrospectives',
      )) {
        Success(:final data) => Success(RemoteStats.retrospectiveYears(data)),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<Retrospective>> getRetrospective(int year) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/me/retrospectives/$year',
    ),
    RemoteStats.retrospective,
  );

  @override
  Future<Result<YearlyGoal>> getGoal(String userId, int year) async => _map(
    await _httpClient.get<Map<String, dynamic>>('${_user(userId)}/goals/$year'),
    RemoteStats.goal,
  );

  @override
  Future<Result<YearlyGoal>> setGoal(int year, int targetMovies) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/me/goals/$year',
      body: {'targetMovies': targetMovies},
    ),
    RemoteStats.goal,
  );

  @override
  Future<Result<void>> removeGoal(int year) async =>
      switch (await _httpClient.delete<dynamic>('$_base/me/goals/$year')) {
        Success() => const Success(null),
        Failure(:final error) => Failure(error),
      };

  String _user(String userId) => '$_base/${Uri.encodeComponent(userId)}';

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };
}
