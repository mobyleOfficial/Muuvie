import 'package:core/core.dart';
import 'package:public_profile_data/datasources/remote/public_profile_remote_data_source.dart';
import 'package:public_profile_domain/models/following_user.dart';
import 'package:public_profile_domain/models/public_profile.dart';
import 'package:public_profile_domain/repositories/public_profile_repository.dart';

class PublicProfileRepositoryImpl implements PublicProfileRepository {
  final PublicProfileRemoteDataSource _remoteDataSource;

  PublicProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<PublicProfile>> getPublicProfile({
    required String userId,
  }) async {
    final result = await _remoteDataSource.getPublicProfile(userId: userId);
    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> followUser({required String userId}) =>
      _remoteDataSource.followUser(userId: userId);

  @override
  Future<Result<void>> unfollowUser({required String userId}) =>
      _remoteDataSource.unfollowUser(userId: userId);

  @override
  Future<Result<List<FollowingUser>>> getMyFollowing() async {
    final result = await _remoteDataSource.getMyFollowing();
    return switch (result) {
      Success(:final data) => Success(data.map((u) => u.toDomain()).toList()),
      Failure(:final error) => Failure(error),
    };
  }
}
