import 'package:core/core.dart';
import 'package:social_network_domain/models/models.dart';
import 'package:social_network_domain/repositories/social_network_repository.dart';

class SetFollowingParams {
  final String userId;

  /// True to follow, false to unfollow.
  final bool follow;

  const SetFollowingParams({required this.userId, required this.follow});
}

/// Follows or unfollows a user (F6.3) and answers how the two relate now.
/// Fails with `tooManyRequests` above 10 follows a minute.
class SetFollowing extends UseCase<SetFollowingParams, Result<FollowStatus>> {
  final SocialNetworkRepository _repository;

  SetFollowing(this._repository);

  @override
  Future<Result<FollowStatus>> call([SetFollowingParams? params]) {
    final value = params!;
    return value.follow
        ? _repository.follow(value.userId)
        : _repository.unfollow(value.userId);
  }
}

class GetFollowStatus extends UseCase<String, Result<FollowStatus>> {
  final SocialNetworkRepository _repository;

  GetFollowStatus(this._repository);

  @override
  Future<Result<FollowStatus>> call([String? userId]) =>
      _repository.getFollowStatus(userId!);
}

/// Which list of a profile to read.
enum FollowList { followers, following }

class GetFollowListParams {
  /// The owner, or `me` for the current user.
  final String userId;
  final FollowList list;
  final int page;

  const GetFollowListParams({
    this.userId = 'me',
    required this.list,
    this.page = 1,
  });
}

/// "Seguindo" and "Seguidores recentes" (F6.3), newest follow first.
class GetFollowList extends UseCase<GetFollowListParams, Result<FollowPage>> {
  final SocialNetworkRepository _repository;

  GetFollowList(this._repository);

  @override
  Future<Result<FollowPage>> call([GetFollowListParams? params]) {
    final value = params!;
    return switch (value.list) {
      FollowList.followers => _repository.getFollowers(
        value.userId,
        page: value.page,
      ),
      FollowList.following => _repository.getFollowing(
        value.userId,
        page: value.page,
      ),
    };
  }
}
