import 'package:core/core.dart';
import 'package:movies_domain/models/movie_review_draft.dart';
import 'package:user_activities_data/datasources/remote/user_activities_remote_data_source.dart';
import 'package:user_activities_data/models/remote/remote_user_activity.dart';
import 'package:user_activities_data/models/remote/remote_user_activity_listing.dart';

class UserActivitiesRemoteDataSourceImpl
    implements UserActivitiesRemoteDataSource {
  // ignore: unused_field
  final HttpClient _httpClient;

  UserActivitiesRemoteDataSourceImpl(this._httpClient);

  static const _mockedActivities = [
    RemoteUserActivity(userName: '', action: 'Watched', movie: 'Dune: Part Two', time: '2h ago'),
    RemoteUserActivity(userName: '', action: 'Reviewed', movie: 'Oppenheimer', time: '1d ago'),
    RemoteUserActivity(userName: '', action: 'Added to watchlist', movie: 'The Brutalist', time: '2d ago'),
    RemoteUserActivity(userName: '', action: 'Liked review of', movie: 'Anora', time: '3d ago'),
    RemoteUserActivity(userName: '', action: 'Watched', movie: 'Poor Things', time: '4d ago'),
    RemoteUserActivity(userName: '', action: 'Reviewed', movie: 'The Substance', time: '5d ago'),
    RemoteUserActivity(userName: '', action: 'Watched', movie: 'Nosferatu', time: '6d ago'),
    RemoteUserActivity(userName: '', action: 'Added to watchlist', movie: 'A Real Pain', time: '1w ago'),
  ];

  static const _mockedFriendsActivities = [
    RemoteUserActivity(userName: 'Alice Martins', action: 'Watched', movie: 'Dune: Part Two', time: '2h ago'),
    RemoteUserActivity(userName: 'Bruno Carvalho', action: 'Reviewed', movie: 'Oppenheimer', time: '3h ago'),
    RemoteUserActivity(userName: 'Camila Torres', action: 'Added to watchlist', movie: 'The Brutalist', time: '5h ago'),
    RemoteUserActivity(userName: 'Diego Ferreira', action: 'Liked review of', movie: 'Anora', time: '1d ago'),
    RemoteUserActivity(userName: 'Elena Souza', action: 'Watched', movie: 'Poor Things', time: '1d ago'),
    RemoteUserActivity(userName: 'Felipe Lima', action: 'Reviewed', movie: 'The Substance', time: '2d ago'),
    RemoteUserActivity(userName: 'Alice Martins', action: 'Watched', movie: 'Nosferatu', time: '3d ago'),
    RemoteUserActivity(userName: 'Bruno Carvalho', action: 'Added to watchlist', movie: 'A Real Pain', time: '4d ago'),
    RemoteUserActivity(userName: 'Camila Torres', action: 'Reviewed', movie: 'Conclave', time: '5d ago'),
    RemoteUserActivity(userName: 'Diego Ferreira', action: 'Watched', movie: 'The Wild Robot', time: '1w ago'),
  ];

  static const int _pageSize = 4;

  @override
  Future<Result<List<RemoteUserActivity>>> getUserActivities({
    required String userId,
  }) async =>
      const Success(_mockedActivities);

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
    final totalPages = (_mockedFriendsActivities.length / _pageSize).ceil();
    final startIndex = (page - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    final pageActivities = _mockedFriendsActivities.sublist(
      startIndex.clamp(0, _mockedFriendsActivities.length),
      endIndex.clamp(0, _mockedFriendsActivities.length),
    );

    return Success(RemoteUserActivityListing(
      totalPages: totalPages,
      totalResults: _mockedFriendsActivities.length,
      activities: pageActivities,
    ));
  }
}
