import 'package:core/core.dart';
import 'package:public_profile_data/models/remote/remote_following_user.dart';
import 'package:public_profile_data/models/remote/remote_public_profile.dart';

abstract interface class PublicProfileRemoteDataSource {
  Future<Result<RemotePublicProfile>> getPublicProfile({
    required String userId,
  });
  Future<Result<void>> followUser({required String userId});
  Future<Result<void>> unfollowUser({required String userId});
  Future<Result<List<RemoteFollowingUser>>> getMyFollowing();
}
