import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

class GetFeedParams {
  final FeedScope scope;
  final String? cursor;

  const GetFeedParams({this.scope = FeedScope.all, this.cursor});
}

/// The Atts tab (F6.2): everyone I follow and me, only them, or only me.
class GetFeed extends UseCase<GetFeedParams, Result<ActivityPage>> {
  final SocialNetworkRepository _repository;

  GetFeed(this._repository);

  @override
  Future<Result<ActivityPage>> call([GetFeedParams? params]) {
    final value = params ?? const GetFeedParams();
    return _repository.getFeed(value.scope, cursor: value.cursor);
  }
}

class GetProfileActivitiesParams {
  /// The owner, or `me` for the current user.
  final String userId;
  final String? cursor;

  const GetProfileActivitiesParams({this.userId = 'me', this.cursor});
}

/// A profile's activities as the current user may see them.
class GetProfileActivities
    extends UseCase<GetProfileActivitiesParams, Result<ActivityPage>> {
  final SocialNetworkRepository _repository;

  GetProfileActivities(this._repository);

  @override
  Future<Result<ActivityPage>> call([GetProfileActivitiesParams? params]) {
    final value = params ?? const GetProfileActivitiesParams();
    return _repository.getUserActivities(value.userId, cursor: value.cursor);
  }
}

class GetMovieActivitiesParams {
  /// Database id of the movie.
  final int movieId;
  final String? cursor;

  /// [FeedScope.all] is everything the user may see, not only people they follow.
  final FeedScope scope;

  /// Avaliações or Atualizações; null for both (B13.3).
  final MovieActivityKind? kind;

  const GetMovieActivitiesParams({
    required this.movieId,
    this.cursor,
    this.scope = FeedScope.following,
    this.kind,
  });
}

/// A movie's activities: the recent ratings of the detail and the Comunidade
/// tab with its type and people filters (B13.3).
class GetMovieActivities
    extends UseCase<GetMovieActivitiesParams, Result<ActivityPage>> {
  final SocialNetworkRepository _repository;

  GetMovieActivities(this._repository);

  @override
  Future<Result<ActivityPage>> call([GetMovieActivitiesParams? params]) {
    final value = params!;
    return _repository.getMovieActivities(
      value.movieId,
      cursor: value.cursor,
      scope: value.scope,
      kind: value.kind,
    );
  }
}

class GetMaratonaProgressParams {
  final String slug;
  final String? cursor;

  const GetMaratonaProgressParams({required this.slug, this.cursor});
}

/// The progress feed of a maratona (F7.6): created, joined, challenges done.
class GetMaratonaProgress
    extends UseCase<GetMaratonaProgressParams, Result<ActivityPage>> {
  final SocialNetworkRepository _repository;

  GetMaratonaProgress(this._repository);

  @override
  Future<Result<ActivityPage>> call([GetMaratonaProgressParams? params]) {
    final value = params!;
    return _repository.getMaratonaProgress(value.slug, cursor: value.cursor);
  }
}

class ToggleLoveParams {
  final int activityId;

  /// True to give an "amei", false to take it back.
  final bool love;

  const ToggleLoveParams({required this.activityId, required this.love});
}

/// "Amei" on any activity the user can see (F6.2).
class ToggleActivityLove
    extends UseCase<ToggleLoveParams, Result<ActivityLoves>> {
  final SocialNetworkRepository _repository;

  ToggleActivityLove(this._repository);

  @override
  Future<Result<ActivityLoves>> call([ToggleLoveParams? params]) {
    final value = params!;
    return value.love
        ? _repository.love(value.activityId)
        : _repository.unlove(value.activityId);
  }
}

class HideActivityParams {
  final int activityId;
  final bool hidden;

  const HideActivityParams({required this.activityId, required this.hidden});
}

/// Hides one of my activities from everyone else's feed, or shows it again.
class HideActivity extends UseCase<HideActivityParams, Result<void>> {
  final SocialNetworkRepository _repository;

  HideActivity(this._repository);

  @override
  Future<Result<void>> call([HideActivityParams? params]) {
    final value = params!;
    return _repository.setHidden(value.activityId, value.hidden);
  }
}
