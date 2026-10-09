import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:movies/movies.dart';
import 'package:objectbox/objectbox.dart';
import 'package:user_activities/user_activities.dart';

@module
abstract class UserActivitiesModule {
  @lazySingleton
  UserActivitiesRemoteDataSource userActivitiesRemoteDataSource(
    @Named('backend') HttpClient httpClient,
  ) => UserActivitiesRemoteDataSourceImpl(httpClient);

  @lazySingleton
  UserActivitiesLocalDataSource userActivitiesLocalDataSource(
    Store store,
    LocalClient localClient,
  ) => UserActivitiesLocalDataSourceImpl(
    store.box<LocalMovieReviewDraft>(),
    localClient,
  );

  @lazySingleton
  UserActivitiesRepository userActivitiesRepository(
    UserActivitiesRemoteDataSource remoteDataSource,
    UserActivitiesLocalDataSource localDataSource,
  ) => UserActivitiesRepositoryImpl(remoteDataSource, localDataSource);

  @injectable
  GetUserActivities getUserActivities(UserActivitiesRepository repository) =>
      GetUserActivities(repository);

  @injectable
  UpsertMovieReview upsertMovieReview(UserActivitiesRepository repository) =>
      UpsertMovieReview(repository);

  @injectable
  ObserveMovieReviewDraftsList observeMovieReviewDraftsList(
    UserActivitiesRepository repository,
  ) => ObserveMovieReviewDraftsList(repository);

  @injectable
  DeleteDraft deleteDraft(UserActivitiesRepository repository) =>
      DeleteDraft(repository);

  @injectable
  GetFriendsActivities getFriendsActivities(
    UserActivitiesRepository repository,
  ) => GetFriendsActivities(repository);

  @injectable
  SubmitReview submitReview(UserActivitiesRepository repository) =>
      SubmitReview(repository);

  @injectable
  ObserveSubmittingDrafts observeSubmittingDrafts(
    UserActivitiesRepository repository,
  ) => ObserveSubmittingDrafts(repository);
}
