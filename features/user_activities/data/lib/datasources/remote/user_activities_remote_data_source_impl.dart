import 'package:core/core.dart';
import 'package:movies_domain/models/movie_review_draft.dart';
import 'package:user_activities_data/datasources/remote/user_activities_remote_data_source.dart';
import 'package:user_activities_data/models/remote/remote_user_activity.dart';
import 'package:user_activities_data/models/remote/remote_user_activity_listing.dart';

class UserActivitiesRemoteDataSourceImpl
    implements UserActivitiesRemoteDataSource {
  final HttpClient _httpClient;

  UserActivitiesRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<List<RemoteUserActivity>>> getUserActivities({
    required String userId,
  }) async {
    final result = await _httpClient.get<List<dynamic>>('/activities/$userId');
    return switch (result) {
      Success(:final data) => Success(
        data
            .cast<Map<String, dynamic>>()
            .map(RemoteUserActivity.fromJson)
            .toList(),
      ),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> submitReview({required MovieReviewDraft draft}) async {
    final result = await _httpClient.post<dynamic>(
      'reviews',
      body: {
        'movieId': draft.movieId,
        'movieTitle': draft.movieTitle,
        'posterPath': draft.posterPath.isNotEmpty ? draft.posterPath : null,
        'reviewTitle': draft.reviewTitle,
        'reviewBody': draft.reviewBody,
        'rating': draft.rating,
        'isFavorite': draft.isFavorite,
        'isRewatch': draft.isRewatch,
        'tags': draft.tags,
      },
    );
    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteUserActivityListing>> getFriendsActivities({
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/activities/friends',
      queryParams: {'page': page},
    );
    return switch (result) {
      Success(:final data) => Success(RemoteUserActivityListing.fromJson(data)),
      Failure(:final error) => Failure(error),
    };
  }
}
