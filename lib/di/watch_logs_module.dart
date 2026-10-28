import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:watch_logs/watch_logs.dart';

@module
abstract class WatchLogsModule {
  @lazySingleton
  WatchLogsRemoteDataSource watchLogsRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => WatchLogsRemoteDataSourceImpl(httpClient);

  @lazySingleton
  WatchLogsRepository watchLogsRepository(
    WatchLogsRemoteDataSource remoteDataSource,
  ) => WatchLogsRepositoryImpl(remoteDataSource);

  @injectable
  GetMovieWatchState getMovieWatchState(WatchLogsRepository repository) =>
      GetMovieWatchState(repository);

  @injectable
  LogWatchSession logWatchSession(WatchLogsRepository repository) =>
      LogWatchSession(repository);

  @injectable
  UpdateWatchLog updateWatchLog(WatchLogsRepository repository) =>
      UpdateWatchLog(repository);

  @injectable
  DeleteWatchLog deleteWatchLog(WatchLogsRepository repository) =>
      DeleteWatchLog(repository);

  @injectable
  GetMovieLogs getMovieLogs(WatchLogsRepository repository) =>
      GetMovieLogs(repository);

  @injectable
  GetUserDiary getUserDiary(WatchLogsRepository repository) =>
      GetUserDiary(repository);

  @injectable
  StartRewatch startRewatch(WatchLogsRepository repository) =>
      StartRewatch(repository);

  @injectable
  SetMovieRating setMovieRating(WatchLogsRepository repository) =>
      SetMovieRating(repository);

  @injectable
  RemoveMovieRating removeMovieRating(WatchLogsRepository repository) =>
      RemoveMovieRating(repository);

  @injectable
  SetWatchingNow setWatchingNow(WatchLogsRepository repository) =>
      SetWatchingNow(repository);

  @injectable
  GetWatchingNow getWatchingNow(WatchLogsRepository repository) =>
      GetWatchingNow(repository);

  @injectable
  GetRecentEmotions getRecentEmotions(WatchLogsRepository repository) =>
      GetRecentEmotions(repository);

  @injectable
  GetRecentGifs getRecentGifs(WatchLogsRepository repository) =>
      GetRecentGifs(repository);

  @injectable
  SearchGifs searchGifs(WatchLogsRepository repository) =>
      SearchGifs(repository);

  @injectable
  GetThreadComments getThreadComments(WatchLogsRepository repository) =>
      GetThreadComments(repository);

  @injectable
  PostThreadComment postThreadComment(WatchLogsRepository repository) =>
      PostThreadComment(repository);

  @injectable
  DeleteThreadComment deleteThreadComment(WatchLogsRepository repository) =>
      DeleteThreadComment(repository);
}
