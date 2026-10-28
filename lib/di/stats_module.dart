import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:stats/stats.dart';

@module
abstract class StatsModule {
  @lazySingleton
  StatsRemoteDataSource statsRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => StatsRemoteDataSourceImpl(httpClient);

  @lazySingleton
  StatsRepository statsRepository(StatsRemoteDataSource remoteDataSource) =>
      StatsRepositoryImpl(remoteDataSource);

  @injectable
  GetStatsYears getStatsYears(StatsRepository repository) =>
      GetStatsYears(repository);

  @injectable
  GetYearStats getYearStats(StatsRepository repository) =>
      GetYearStats(repository);

  @injectable
  GetStatsCalendar getStatsCalendar(StatsRepository repository) =>
      GetStatsCalendar(repository);

  @injectable
  GetRetrospectiveYears getRetrospectiveYears(StatsRepository repository) =>
      GetRetrospectiveYears(repository);

  @injectable
  GetRetrospective getRetrospective(StatsRepository repository) =>
      GetRetrospective(repository);

  @injectable
  GetYearlyGoal getYearlyGoal(StatsRepository repository) =>
      GetYearlyGoal(repository);

  @injectable
  SetYearlyGoal setYearlyGoal(StatsRepository repository) =>
      SetYearlyGoal(repository);
}
