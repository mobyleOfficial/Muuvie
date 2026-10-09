import 'package:core/core.dart';
import 'package:public_profile_data/datasources/remote/public_profile_remote_data_source.dart';
import 'package:public_profile_data/models/remote/remote_following_user.dart';
import 'package:public_profile_data/models/remote/remote_public_profile.dart';

class PublicProfileRemoteDataSourceImpl
    implements PublicProfileRemoteDataSource {
  final HttpClient _httpClient;

  PublicProfileRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<RemotePublicProfile>> getPublicProfile({
    required String userId,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/profile/$userId',
    );
    return switch (result) {
      Success(:final data) => Success(RemotePublicProfile.fromJson(data)),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> followUser({required String userId}) async {
    final result = await _httpClient.post<dynamic>('/users/$userId/follow');
    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> unfollowUser({required String userId}) async {
    final result = await _httpClient.delete<dynamic>('/users/$userId/follow');
    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteFollowingUser>>> getMyFollowing() async {
    final result = await _httpClient.get<List<dynamic>>('/users/me/following');
    return switch (result) {
      Success(:final data) => Success(
        data
            .cast<Map<String, dynamic>>()
            .map(RemoteFollowingUser.fromJson)
            .toList(),
      ),
      Failure(:final error) => Failure(error),
    };
  }
}
